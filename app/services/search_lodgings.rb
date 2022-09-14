class SearchLodgings
  attr_accessor :params
  attr_reader :custom_text, :only_parent

  def self.call(params, custom_text=nil, only_parent=false)
    self.new(params, custom_text, only_parent).call
  end

  def initialize(params, custom_text=nil, only_parent=false)
    @params = params
    @custom_text = custom_text
    @only_parent = only_parent
  end

  def call
    Lodging.search body: body, page: params[:page], per_page: 18, limit: params[:limit], includes: [:translations, { parent: :translations }]
  end

  private
    def query
      params[:query].presence || "*"
    end

    def body
      body = {}
      body[:query] = { bool: boolean_queries }
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

      conditions << { terms: { presentation: ['as_child', 'as_standalone'] } } unless only_parent
      conditions << { term: { presentation: 'as_parent' } } if only_parent

      conditions << { range: { beds: { gte: params[:beds], lte: params[:beds].to_i + 1 } } } if params[:beds].present?
      conditions << { range: { baths: { gte: params[:baths], lte: params[:baths].to_i + 1 } } } if params[:baths].present?
      conditions << { range: { adults: { gte: params[:adults] } } } if params[:adults].present?
      conditions << { range: { adults_and_children: { gte: (params[:adults].to_i + params[:children].to_i) } } } if params[:adults].present?
      conditions << { range: { minimum_adults: { lte: params[:adults] } } } if params[:adults].present?
      conditions << { range: { availability_price: { gte: params[:min_price], lte: params[:max_price] } } } if params[:min_price].present? && params[:max_price].present?

      if params[:countries_in].present? && params[:countries_in].reject(&:empty?).present? && params[:regions_in].present? && params[:bounds].blank?
        conditions << { bool: { should: [countries_in, regions_in] }}
      elsif params[:countries_in].present? && params[:countries_in].reject(&:empty?).present? && params[:bounds].blank?
        conditions << countries_in
      elsif params[:regions_in].present? && params[:regions_in].reject(&:empty?).present? && params[:bounds].blank?
        conditions << regions_in
      end

      unless params[:flexible_arrival].present?
        conditions << flexibility_condition if params[:check_in].present?
        conditions << minimum_stay_condition if params[:check_in].present? && params[:check_out].present?
      end

      conditions << frame_coordinates if params[:bounds].present?
      conditions << near_latlong_condition if params[:within].present?

      availability_condition conditions if params[:check_in].present? || params[:check_out].present?
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

    def flexibility_condition
      check_in = Date.parse(params[:check_in])
      {
        bool: {
          should: [
            { match: { flexible_arrival: true } },
            {
              nested: {
                path: :rules,
                query: {
                  bool: {
                    should: [
                      {
                        bool: {
                          must: [
                            { match: { "rules.dates": check_in } },
                            { match: { "rules.flexible_arrival": true } },
                          ]
                        }
                      },
                      {
                        bool: {
                          must: [
                            { match: { "rules.dates": check_in } },
                            { match: { "rules.flexible_arrival": false } },
                            { match: { "rules.checkin_day": check_in.strftime("%A").downcase } }
                          ]
                        }
                      }
                    ]
                  }
                },
              },
            },
            {
              bool: {
                must: [
                  { match: { flexible_arrival: false } },
                  { match: { check_in_day: check_in.strftime("%A").downcase } }
                ]
              }
            }
          ]
        }
      }
    end

    def minimum_stay_condition
      check_in, check_out = Date.parse(params[:check_in]), Date.parse(params[:check_out])
      nights = (check_out - check_in).to_i
      {
        bool: {
          filter: [
            {
              nested: {
                path: :rules,
                query: {
                  bool: {
                    should: [
                      {
                        bool: {
                          must: [
                            { match: { "rules.minimum_stay": nights } },
                            { match: { "rules.dates": check_in } },
                          ]
                        }
                      },
                      {
                        bool: {
                          must: [
                            { match: { "rules.minimum_stay": 0 } },
                            { match: { "rules.dates": check_in } },
                          ]
                        }
                      }
                    ]
                  }
                },
              },
            }
          ]
        }
      }
    end

    def availability_condition conditions
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      return all(:available_on, (Date.parse(check_in)..Date.parse(check_out)).map(&:to_s), conditions) unless params[:flexible_arrival].present?

      dates = []
      3.times do |index|
        dates << all(:available_on, ((Date.parse(check_in) + index.day)..(Date.parse(check_out) + index.day)).map(&:to_s), [])
        next if index == 0
        dates << all(:available_on, ((Date.parse(check_in) - index.day)..(Date.parse(check_out) - index.day)).map(&:to_s), [])
        dates << all(:available_on, ((Date.parse(check_in) + index.day)..(Date.parse(check_out))).map(&:to_s), [])
        dates << all(:available_on, ((Date.parse(check_in))..(Date.parse(check_out) - index.day)).map(&:to_s), [])
        dates << all(:available_on, ((Date.parse(check_in) + index.day)..(Date.parse(check_out) - index.day)).map(&:to_s), []) if index == 1
      end

      should = []
      dates.each { |date_range| should << { bool: { must: date_range } } }

      conditions << { bool: { should: should } }
    end

    def order
      return { average_rating: :desc } if params[:order] == 'rating_desc'
      return { price: :asc } if params[:order] == 'price_asc'
      return { price: :desc } if params[:order] == 'price_desc'
      return { created_at: :desc } if params[:order] == 'new_desc'
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
end
