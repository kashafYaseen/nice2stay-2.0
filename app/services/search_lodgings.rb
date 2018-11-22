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
    Lodging.search body: body
    #Lodging.search query, where: conditions, aggs: [:beds, :baths, :lodging_type, :amenities, :experiences], per_page: 18, page: params[:page], order: order, limit: params[:limit], includes: [:translations]
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
      conditions << { term: { country: params[:country] } } if params[:country].present? && params[:bounds].blank?
      conditions << { term: { region: params[:region] } } if params[:region].present? && params[:bounds].blank?

      conditions << { term: { id: 1 } }

      conditions << { terms: { lodging_type: params[:lodging_type_in] } } if params[:lodging_type_in].present?
      conditions << { terms: { presentation: ['as_parent', 'as_standalone'] } }

      conditions << { range: { beds: { gte: params[:beds] } } } if params[:beds].present?
      conditions << { range: { baths: { gte: params[:baths] } } } if params[:baths].present?
      conditions << { range: { adults: { gte: params[:adults] } } } if params[:adults].present?
      conditions << { range: { minimum_adults: { lte: params[:adults] } } } if params[:adults].present?
      conditions << { range: { availability_price: { gte: params[:min_price], lte: params[:max_price] } } } if params[:min_price].present? && params[:max_price].present?

      conditions << rules_condition if params[:check_in].present?

      conditions << frame_coordinates if params[:bounds].present?
      conditions << near_latlong_condition if params[:within].present?

      availability_condition conditions if params[:check_in].present? || params[:check_out].present?
      all(:amenities, params[:amenities_in], conditions) if params[:amenities_in].present?
      all(:experiences, params[:experiences_in], conditions) if params[:experiences_in].present?

      # merge_seo_filters
      # conditions = {}
      # conditions[:beds]         = { gte: params[:beds] } if params[:beds].present?
      # conditions[:baths]        = { gte: params[:baths] } if params[:baths].present?
      # conditions[:lodging_type] = params[:lodging_type_in] if params[:lodging_type_in].present?
      # conditions[:available_on] = availability_condition if params[:check_in].present? || params[:check_out].present?
      # conditions[:location]     = near_condition if params[:near].present?
      # conditions[:location]     = frame_coordinates if params[:bounds].present?
      # conditions[:location]     = near_latlong_condition if params[:within].present?
      # conditions[:adults]       = { gte: params[:adults] }  if params[:adults].present?
      # conditions[:minimum_adults] = { lte: params[:adults] }  if params[:adults].present?
      # conditions[:_or]          = adults_plus_children if params[:adults].present? && params[:children].present?
      # conditions[:country]      = params[:country] if params[:country].present? && params[:bounds].blank?
      # conditions[:region]       = params[:region] if params[:region].present? && params[:bounds].blank?
      # conditions[:availability_price] = price_range if params[:min_price].present? && params[:max_price].present?
      # conditions[:presentation] = ['as_parent', 'as_standalone']
      # conditions[:amenities]    = { all: params[:amenities_in] } if params[:amenities_in].present?
      # conditions[:experiences]  = { all: params[:experiences_in] } if params[:experiences_in].present?
      # conditions[:id]           = { not: params[:lodging_id] } if params[:lodging_id].present?
      conditions
    end

    def aggregation
      {
        lodging_type: { terms: { field: :lodging_type } },
        amenities: { terms: { field: :amenities } },
        experiences: { terms: { field: :experiences } },
      }
    end

    def frame_coordinates
      sw_lat, sw_lng, ne_lat, ne_lng = params[:bounds].split(",")
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

    def rules_condition
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
                            { match: { "rules.dates": Date.parse(params[:check_in]) } },
                            { match: { "rules.flexible_arrival": true } },
                          ]
                        }
                      },
                      {
                        bool: {
                          must: [
                            { match: { "rules.dates": Date.parse(params[:check_in]) } },
                            { match: { "rules.flexible_arrival": false } },
                            { match: { "rules.check_in_day": Date.parse(params[:check_in]).strftime("%A").downcase } }
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
      return all(:available_on, (Date.parse(check_in)..Date.parse(check_out)).map(&:to_s), conditions)

      # return { all: (Date.parse(check_in)..Date.parse(check_out)).map(&:to_s) } unless params[:flexible_arrival].present?

      # dates = []
      # 3.times do |index|
      #   dates << ((Date.parse(check_in) + index.day)..(Date.parse(check_out) + index.day)).map(&:to_s)
      #   dates << ((Date.parse(check_in) - index.day)..(Date.parse(check_out) - index.day)).map(&:to_s) unless index == 0
      #   dates << ((Date.parse(check_in) + index.day)..(Date.parse(check_out))).map(&:to_s)
      #   dates << ((Date.parse(check_in))..(Date.parse(check_out) - index.day)).map(&:to_s)
      #   dates << ((Date.parse(check_in) + index.day)..(Date.parse(check_out) - index.day)).map(&:to_s) if index == 1
      # end

      # { all: dates }
    end

    # def price_range
    #   { gte: params[:min_price], lte: params[:max_price] }
    # end

    def order
      return { average_rating: :desc } if params[:order] == 'rating_desc'
      return { price: :asc } if params[:order] == 'price_asc'
      return { price: :desc } if params[:order] == 'price_desc'
      return { created_at: :desc } if params[:order] == 'new_desc'
    end

    # def adults_plus_children
    #   [
    #     { children: { gte: params[:children].to_i } },
    #     { adults_and_children: { gte: (params[:adults].to_i + params[:children].to_i) } }
    #   ]
    # end

    # def merge_seo_filters
    #   return unless custom_text.present?
    #   params[:experiences_in] = [custom_text.experience_slug] if custom_text.experience.present?
    #   params[:country] = custom_text.country_slug if custom_text.country.present?
    #   params[:region] = custom_text.region_slug if custom_text.region.present?
    #   params[:lodging_type_in] = [lodging_type(custom_text.category)] if custom_text.category?
    # end

    # def lodging_type(type)
    #   return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(type)
    #   return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(type)
    #   return 'bnb' if ["boutique-hotels", "boutique-hotels", "bnb"].include?(type)
    # end

    def all term, values, query
      values.each do |value|
        query << { term: { term => value } }
      end
      query
    end
end
