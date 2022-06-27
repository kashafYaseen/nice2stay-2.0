class V2::SearchLodgings
  attr_accessor :params
  attr_reader :custom_text, :search_analytic

  def self.call(params, search_analytic, custom_text=nil)
    self.new(params, search_analytic, custom_text).call
  end

  def initialize(params, search_analytic, custom_text=nil)
    @params = params
    @custom_text = custom_text
    @search_analytic = search_analytic
  end

  def call
    cache_key = [self.class.name, __method__, search_analytic.params['lodgings']]
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      Lodging.search body: body, page: params[:page], per_page: 18, limit: params[:limit], includes: [:translations, :lodging_children, :children_room_rates, { price_text: :translations }, { region: :country }, { parent: :translations }]
    end
  end

  private
    def query
      params[:query].presence || "*"
    end

    def body
      queries = boolean_queries
      body = {}
      body[:query] = {
        bool: {
          should: [
            {
              has_child: { type: :child, query: { bool: queries }, inner_hits: { _source: ['id'] } }
            },
            { bool: queries.merge({ filter: queries[:filter].clone.push({ term: { presentation: :as_standalone } }) }) }
          ]
        }
      }

      body[:sort] = [order] if order.present?
      body[:aggs] = aggregation
      body
    end

    def boolean_queries
      boolean_queries = {}
      boolean_queries[:filter] = conditions
      boolean_queries[:must_not] = { term: { id: params[:lodging_id] } } if params[:lodging_id].present?
      boolean_queries
    end

    def conditions
      conditions = []
      merge_seo_filters conditions
      conditions << { terms: { id: Lodging.search(params[:name_middle]).hits.collect{ |hit| hit['_id'].to_i } } } if params[:name_middle].present?
      conditions << { term: { published: true } }
      conditions << { terms: { id: params[:lodging_ids] } } if params[:lodging_ids].present?
      conditions << { term: { checked: params[:checked] } } if params[:checked].present?
      conditions << { term: { discounts: true } } if params[:discounts].present?
      conditions << { term: { realtime_availability: true } } if params[:realtime_availability].present?
      conditions << { term: { free_cancelation: true } } if params[:free_cancelation].present?
      conditions << { terms: { lodging_type: params[:lodging_type_in] } } if params[:lodging_type_in].present?
      conditions << { range: { beds: { gte: params[:beds], lte: params[:beds].to_i + 1 } } } if params[:beds].present?
      conditions << { range: { baths: { gte: params[:baths], lte: params[:baths].to_i + 1 } } } if params[:baths].present?

      if params[:adults].present? && params[:perfect_adults].present?
        conditions << { range: { adults: { gte: params[:adults].to_i, lte: params[:perfect_adults].to_i } } }
      elsif params[:adults].present?
        conditions << { range: { adults: { gte: params[:adults].to_i } } }
        conditions << { range: { adults_and_children: { gte: (params[:adults].to_i + params[:children].to_i) } } }
        conditions << { range: { minimum_adults: { lte: params[:adults].to_i } } }
      end

      conditions << { range: { availability_price: { gte: params[:min_price], lte: params[:max_price] } } } if params[:min_price].present? && params[:max_price].present?

      if params[:countries_in].present? && params[:countries_in].reject(&:empty?).present? && params[:regions_in].present? && params[:bounds].blank?
        conditions << { bool: { should: [countries_in, regions_in] }}
      elsif params[:countries_in].present? && params[:countries_in].reject(&:empty?).present? && params[:bounds].blank?
        conditions << countries_in
      elsif params[:regions_in].present? && params[:regions_in].reject(&:empty?).present? && params[:bounds].blank?
        conditions << regions_in
      end

      conditions << frame_coordinates if params[:bounds].present?
      conditions << near_latlong_condition if params[:within].present?

      availability_condition conditions if params[:check_in].present? || params[:check_out].present? || params[:flexible_dates].present?
      all(:amenities_ids, params[:amenities_in], conditions) if params[:amenities_in].present?
      all(:experiences, params[:experiences_in], conditions) if params[:experiences_in].present?

      conditions
    end

    def countries_in
      { terms: { country: params[:countries_in] } }
    end

    def regions_in
      { terms: { region: params[:regions_in] } }
    end

    def aggregation
      {
        lodging_type: { terms: { field: :lodging_type } },
        countries: { terms: { field: :country_id } },
        amenities: { terms: { field: :amenities_ids, size: Amenity.count } },
        experiences: { terms: { field: :experiences_ids, size: Experience.count } },
        discounts: { terms: { field: :discounts } },
        checked: { terms: { field: :checked } },
        realtime_availability: { terms: { field: :realtime_availability } },
        free_cancelation: { terms: { field: :free_cancelation } },
      }
    end

    def frame_coordinates
      sw_lng, sw_lat, ne_lng, ne_lat = params[:bounds].split(",")
      return if sw_lng == ne_lng || sw_lat == ne_lat
      {
        geo_bounding_box: {
          location: {
            top_left: {
              lat: ne_lat,
              lon: sw_lng
            },
            bottom_right: {
              lat: sw_lat,
              lon: ne_lng
            }
          }
        }
      }
    end

    def near_condition
      location = Geocoder.search(params[:near]).first
      {
        near: {
          lat: location.latitude,
          lon: location.longitude
        },
        within: "3mi"
      }
    end

    def near_latlong_condition
      {
        geo_distance: {
          distance: params[:within],
          location: {
            lat: params[:latitude],
            lon: params[:longitude]
          },
        }
      }
    end

    def rules_condition(dates)
      {
        bool: {
          should: [
            {
              nested: {
                path: :rules,
                query: {
                  bool: {
                    must: [
                      { terms: { "rules.dates": dates } },
                      { term: { "rules.minimum_stay": total_nights(dates[0], dates[-1]) } },
                      {
                        bool: {
                          should: [
                            { match: { flexible_arrival: true } },
                            { match: { "rules.flexible_arrival": true } },
                            {
                              bool: {
                                must: [
                                  { match: { "rules.flexible_arrival": false } },
                                  { term: { "rules.check_in_day": Date.parse(dates[0]).strftime("%A").downcase } }
                                ]
                              }
                            },
                            {
                              bool: {
                                must: [
                                  { match: { flexible_arrival: false } },
                                  { term: { check_in_day: Date.parse(dates[0]).strftime("%A").downcase } }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ]
                  }
                }
              }
            }
          ]
        }
      }
    end

    def availability_condition conditions
      flexible_days = params[:flexible_days].presence || 3
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      return conditions << check_availabilities((Date.parse(check_in)..Date.parse(check_out)).map(&:to_s)) unless params[:flexible_arrival].present?

      _conditions = []
      if params[:flexible_type].present?
        params[:flexible_dates].each do |date_range|
          _conditions << check_availabilities((Date.parse(date_range[:check_in])..Date.parse(date_range[:check_out])).map(&:to_s))
        end
      else
        flexible_days.to_i.times do |index|
          _conditions << check_availabilities(((Date.parse(check_in) + index.day)..Date.parse(check_out) + index.day).map(&:to_s))
          next if index == 0

          _conditions << check_availabilities(((Date.parse(check_in) - index.day)..Date.parse(check_out) - index.day).map(&:to_s))
          _conditions << check_availabilities(((Date.parse(check_in) + index.day)..Date.parse(check_out)).map(&:to_s))
          _conditions << check_availabilities(((Date.parse(check_in))..Date.parse(check_out) - index.day).map(&:to_s))
          next unless index == 1

          _conditions << check_availabilities(((Date.parse(check_in) + index.day)..Date.parse(check_out) - index.day).map(&:to_s))
        end
      end

      conditions << { bool: { should: _conditions } }
    end

    def check_availabilities(dates)
      {
        bool: {
          should: [
            available_on(dates),
            { bool: { must: [rate_enabled, available_on(dates, true)] } }
          ]
        }
      }
    end

    def available_on(dates, channel_manager = false)
      conditions = []
      dates.each do |date|
        condition = channel_manager ? check_channel_manager_availability(date) : check_standard_availability(date)
        conditions << condition
      end

      return checkin_to_checkout_condition(dates, conditions) if channel_manager

      {
        bool: {
          must: [
            { bool: { must: conditions } },
            rules_condition(dates)
          ]
        }
      }
    end

    def check_standard_availability(date)
      {
        nested: {
          path: :availabilities,
          query: {
            bool: {
              must: [
                { term: { 'availabilities.available_on': date } },
                { term: { 'availabilities.check_out_only': false } }
              ]
            }
          }
        }
      }
    end

    def rate_enabled
      {
        bool: {
          must: [
            {
              nested: {
                path: :room_rates,
                query: {
                  term: { 'room_rates.rate_enabled': true }
                }
              }
            }
          ]
        }
      }
    end

    def check_channel_manager_availability(date)
      {
        nested: {
          path: 'room_rates.availabilities',
          query: {
            bool: {
              must: [
                { term: { 'room_rates.availabilities.available_on': date } },
                { range: { 'room_rates.availabilities.booking_limit': { gt: 0 } } }
              ]
            }
          }
        }
      }
    end

    def checkin_to_checkout_condition(dates, conditions)
      {
        bool: {
          must: [
            { bool: { must: conditions } },
            {
              nested: {
                path: 'room_rates.availabilities',
                query: {
                  bool: {
                    must: [
                      { term: { 'room_rates.availabilities.available_on': dates[0] } },
                      { term: { 'room_rates.availabilities.minimum_stay': total_nights(dates[0], dates[-1]) } },
                      { term: { 'room_rates.availabilities.check_in_closed': false  } },
                      { range: { "room_rates.availabilities.booking_limit": { gt: 0 } } },
                      {
                        bool: {
                          should: [
                            {
                              bool: {
                                must_not: [
                                  { exists: { field: 'room_rates.availabilities.open_gds_restriction_days' } },
                                  { exists: { field: 'room_rates.availabilities.open_gds_restriction_type' } }
                                ]
                              }
                            },
                            {
                              bool: {
                                must: [
                                  { term: { 'room_rates.availabilities.open_gds_arrival_days': Date.parse(dates[0]).strftime("%A").downcase } },
                                  {
                                    bool: {
                                      should: {
                                        script: {
                                          script: {
                                            source: "String res_type = doc[\"room_rates.availabilities.open_gds_restriction_type\"].value; SimpleDateFormat sdf = new SimpleDateFormat(\"yyyy-MM-dd\"); try { long checkin_date = sdf.parse(params.checkin_date).getTime(); Calendar cal = Calendar.getInstance(); cal.add(Calendar.DATE, (int)doc[\"room_rates.availabilities.open_gds_restriction_days\"].value); long required_check_in = sdf.parse(sdf.format(cal.getTime())).getTime(); if(res_type == \"disabled\" || (res_type == \"till\" && checkin_date >= required_check_in) || (res_type == \"from\" && checkin_date <= required_check_in)) { return true; } return false; } catch(Exception e){ return false; }",
                                            params: {
                                             checkin_date: dates[0]
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ]
                  }
                }
              }
            },
            { term: { checkout_dates: dates[-1] } },
          ]
        }
      }
    end

    def order
      return { beds: :asc } if params[:order] == 'beds_asc'
      return { beds: :desc } if params[:order] == 'beds_desc'
      return { adults: :asc } if params[:order] == 'adults_asc'
      return { adults: :desc } if params[:order] == 'adults_desc'
      return { price: :asc } if params[:order] == 'price_asc'
      return { price: :desc } if params[:order] == 'price_desc'
      return { created_at: :desc } if params[:order] == 'new_desc'
      return { average_rating: :desc } if params[:order] == 'rating_desc'
      return { boost: :asc }
    end

    def merge_seo_filters conditions
      return unless custom_text.present?

      params[:experiences_in] = [custom_text.experience_slug] if custom_text.experience.present?
      params[:countries_in] = [custom_text.country_slug] if custom_text.country.present?
      params[:regions_in] = [custom_text.region_slug] if custom_text.region.present?
      params[:lodging_type_in] = [lodging_type(custom_text.category)] if custom_text.category?
      params[:discounts] = true if custom_text.special_offer?
    end

    def lodging_type(type)
      return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(type)
      return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(type)
      return 'bnb' if ["boutique-hotels", "boutique-hotels", "bnb"].include?(type)
    end

    def all term, values, query
      values.each do |value|
        query << { term: { term => value } }
      end
      query
    end

    def total_nights(check_in, check_out)
      (Date.parse(check_out) - Date.parse(check_in)).to_i
    end

    def embed_params
      params.except(:locale, :months_date_range, :flexible_dates).to_s
    end
end
