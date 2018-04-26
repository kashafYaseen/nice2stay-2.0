class SearchTransactions
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
    Transaction.facets_search(params)
  end

  private

    def search_locations_in_frame
      Transaction.search("*", aggs: [:beds, :baths], page: params[:page], per_page: 10, order: {price: {order: "asc"}}, where: {
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
      Transaction.search "*", page: params[:page], aggs: [:beds, :baths], per_page: 8,
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
