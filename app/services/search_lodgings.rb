class SearchLodgings
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Lodging.search query, where: conditions, aggs: [:beds, :baths, :lodging_type], per_page: 10, page: params[:page], order: order, includes: [:translations]
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
      conditions[:adults]       = params[:adults]  if params[:adults].present?
      conditions[:_or]          = adults_plus_children if params[:adults].present? && params[:children].present?
      conditions[:country]      = params[:region].split(', ').last if params[:region].present?
      conditions[:region]       = params[:region].split(', ').first if params[:region].present?
      conditions[:availability_price] = price_range if params[:min_price].present? && params[:max_price].present?
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

    def availability_condition
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      {
        all: (check_in.to_date..check_out.to_date).map(&:to_s)
      }
    end

    def price_range
      { gte: params[:min_price], lte: params[:max_price] }
    end

    def order
      return { price: :asc } if params[:order] == 'price_asc'
      { price: :desc } if params[:order] == 'price_desc'
    end

    def adults_plus_children
      [
        { children: params[:children].to_i  },
        { adults_and_children: params[:adults].to_i + params[:children].to_i }
      ]
    end
end
