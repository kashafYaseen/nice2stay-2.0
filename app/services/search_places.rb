class SearchPlaces
  attr_accessor :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Place.search where: near_latlong_condition, includes: [:translations, :place_category], order: order
  end

  private
    def near_latlong_condition
      {
        location: {
          near: { lat: params[:latitude], lon: params[:longitude] },
          within: (params[:places_within].presence || '100km' )
        }
      }
    end

    def order
      {
        _geo_distance: {
          location: { lat: params[:latitude], lon: params[:longitude] },
          order: "asc",
          unit: "km"
        }
      }
    end
end
