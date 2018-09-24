class SearchLodgings
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Lodging.search query, where: conditions, aggs: [:beds, :baths, :lodging_type, :amenities, :experiences], per_page: 18, page: params[:page], order: order, limit: params[:limit], includes: [:translations]
  end

  private

    def query
      params[:query].presence || "*"
    end

    def conditions
      conditions = {}
      conditions[:beds]         = { gte: params[:beds] } if params[:beds].present?
      conditions[:baths]        = { gte: params[:baths] } if params[:baths].present?
      conditions[:lodging_type] = params[:lodging_type_in] if params[:lodging_type_in].present?
      conditions[:available_on] = availability_condition if params[:check_in].present? || params[:check_out].present?
      conditions[:location]     = near_condition if params[:near].present?
      conditions[:location]     = frame_coordinates if params[:bounds].present?
      conditions[:location]     = near_latlong_condition if params[:within].present?
      conditions[:adults]       = { gte: params[:adults] }  if params[:adults].present?
      conditions[:_or]          = adults_plus_children if params[:adults].present? && params[:children].present?
      conditions[:country]      = params[:region].split(', ').last if params[:region].present?
      conditions[:region]       = params[:region].split(', ').first if params[:region].present?
      conditions[:availability_price] = price_range if params[:min_price].present? && params[:max_price].present?
      conditions[:presentation] = ['as_parent', 'as_standalone']
      conditions[:amenities]    = { all: params[:amenities_in] } if params[:amenities_in].present?
      conditions[:experiences]  = { all: params[:experiences_in] } if params[:experiences_in].present?
      conditions[:id]           = { not: params[:lodging_id] } if params[:lodging_id].present?
      conditions
    end

    def frame_coordinates
      sw_lat, sw_lng, ne_lat, ne_lng = params[:bounds].split(",")
      {
        top_left: {
          lat: ne_lat,
          lon: sw_lng
        },
        bottom_right: {
          lat: sw_lat,
          lon: ne_lng
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
        near: {
          lat: params[:latitude],
          lon: params[:longitude]
        },
        within: params[:within]
      }
    end

    def availability_condition
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      {
        all: (Date.parse(check_in)..Date.parse(check_out)).map(&:to_s)
      }
    end

    def price_range
      { gte: params[:min_price], lte: params[:max_price] }
    end

    def order
      return { average_rating: :desc } if params[:order] == 'rating_desc'
      return { price: :asc } if params[:order] == 'price_asc'
      return { price: :desc } if params[:order] == 'price_desc'
      return { created_at: :desc } if params[:order] == 'new_desc'
    end

    def adults_plus_children
      [
        { children: { gte: params[:children].to_i } },
        { adults_and_children: { gte: (params[:adults].to_i + params[:children].to_i) } }
      ]
    end
end
