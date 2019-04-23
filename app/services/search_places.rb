class SearchPlaces
  attr_accessor :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Place.search where: where, includes: [:translations, :place_category], order: order
  end

  private
    def where
      {
        location: {
          near: { lat: params[:latitude], lon: params[:longitude] },
          within: (params[:places_within].presence || '100km' )
        },
        publish: true,
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
