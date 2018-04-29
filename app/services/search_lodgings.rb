class SearchLodgings
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Lodging.search query, where: conditions, aggs: [:beds, :baths], per_page: 10, page: params[:page]
  end

  private

    def query
      params[:query].presence || "*"
    end

    def conditions
      conditions = {}
      conditions[:beds]         = { gte: params[:beds] } if params[:beds].present?
      conditions[:baths]        = { gte: params[:baths] } if params[:baths].present?
      conditions[:adults]       = { gte: params[:adults] } if params[:adults].present?
      conditions[:children]     = { gte: params[:children] } if params[:children].present?
      conditions[:babies]       = { gte: params[:babies] } if params[:babies].present?
      conditions[:lodging_type] = { all: params[:lodging_type_in] } if params[:lodging_type_in].present?
      conditions[:location]     = near_condition if params[:near].present?
      conditions[:location]     = frame_coordinates if params[:l].present?
      conditions
    end

    def frame_coordinates
      sw_lat, sw_lng, ne_lat, ne_lng = params[:l].split(",")
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
end
