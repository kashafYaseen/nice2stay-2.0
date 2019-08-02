class SearchLodgings
  attr_accessor :params
  attr_reader :custom_text

  def self.call(params, custom_text=nil)
    self.new(params, custom_text).call
  end

  def initialize(params, custom_text=nil)
    @params = params
    @custom_text = custom_text
  end

  def call
    Lodging.search body: body, page: params[:page], per_page: 10, limit: params[:limit], includes: [:translations, { parent: :translations }]
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
      conditions << { term: { checked: params[:checked] } } if params[:checked].present?
      conditions << { term: { country: params[:country] } } if params[:country].present? && params[:bounds].blank?
      conditions << { term: { region: params[:region] } } if params[:region].present? && params[:bounds].blank?
      conditions << { term: { discounts: true } } if params[:discounts].present?

      conditions << { terms: { country: params[:countries_in] } } if params[:countries_in].present?

      conditions << { terms: { lodging_type: params[:lodging_type_in] } } if params[:lodging_type_in].present?
      conditions << { terms: { presentation: ['as_child', 'as_standalone'] } }

      conditions << { range: { beds: { gte: params[:beds] } } } if params[:beds].present?
      conditions << { range: { baths: { gte: params[:baths] } } } if params[:baths].present?
      conditions << { range: { adults: { gte: params[:adults] } } } if params[:adults].present?
      conditions << { range: { adults_and_children: { gte: (params[:adults].to_i + params[:children].to_i) } } } if params[:adults].present?
      conditions << { range: { minimum_adults: { lte: params[:adults] } } } if params[:adults].present?
      conditions << { range: { availability_price: { gte: params[:min_price], lte: params[:max_price] } } } if params[:min_price].present? && params[:max_price].present?

      unless params[:flexible_arrival].present?
        conditions << flexibility_condition if params[:check_in].present?
        conditions << minimum_stay_condition if params[:check_in].present? && params[:check_out].present?
      end

      conditions << frame_coordinates if params[:bounds].present?
      conditions << near_latlong_condition if params[:within].present?

      availability_condition conditions if params[:check_in].present? || params[:check_out].present?
      all(:amenities, params[:amenities_in], conditions) if params[:amenities_in].present?
      all(:experiences, params[:experiences_in], conditions) if params[:experiences_in].present?

      conditions
    end

    def aggregation
      {
        lodging_type: { terms: { field: :lodging_type } },
        countries: { terms: { field: :country_id } },
        amenities: { terms: { field: :amenities_ids, size: Amenity.count } },
        experiences: { terms: { field: :experiences_ids, size: Experience.count } },
        discounts: { terms: { field: :discounts } },
        checked: { terms: { field: :checked } },
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
                            { match: { "rules.check_in_day": check_in.strftime("%A").downcase } }
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
                            { range: { "rules.minimum_stay": { lte: nights } } },
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
      params[:country] = custom_text.country_slug if custom_text.country.present?
      params[:region] = custom_text.region_slug if custom_text.region.present?
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
