class SearchLodgings
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    return search_locations_in_frame if params[:l].present?
    return search_near if params[:near].present?
    Lodging.search query, where: conditions, aggs: [:beds, :baths], per_page: 10, page: params[:page]
  end

  private

    def query
      params[:query].presence || "*"
    end

    def conditions
      conditions = {}
      conditions[:beds] = { gte: params[:beds] } if params[:beds].present?
      conditions[:baths] = { gte: params[:baths] } if params[:baths].present?
      conditions[:adults] = { gte: params[:adults] } if params[:adults].present?
      conditions[:children] = { gte: params[:children] } if params[:children].present?
      conditions[:babies] = { gte: params[:babies] } if params[:babies].present?
      conditions[:lodging_type] = { all: params[:lodging_type_in] } if params[:lodging_type_in].present?
      conditions
    end

    def search_locations_in_frame
      Lodging.search(query, where: conditions, aggs: [:beds, :baths], page: params[:page], per_page: 10, order: {price: {order: "asc"}}, where: {
        location: frame_coordinates
      })
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

    def search_near
      location = Geocoder.search(params[:near]).first
      Lodging.search query, where: conditions, page: params[:page], aggs: [:beds, :baths], per_page: 10,
        boost_by_distance: {location: {origin: {lat: location.latitude, lon: location.longitude}}},
        where: {
          location: {
            near: {
              lat: location.latitude,
              lon: location.longitude
            },
            within: "3mi"
          }
        }
    end
end
