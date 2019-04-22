class SearchPlaces
  attr_accessor :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Place.search body: body, includes: [:translations]
  end

  private
    def body
      body = {}
      body[:query] = { bool: boolean_queries }
      body
    end

    def boolean_queries
      boolean_queries = {}
      boolean_queries[:filter] = conditions
      boolean_queries
    end

    def conditions
      conditions = []
      conditions << near_latlong_condition
      conditions
    end

    def near_latlong_condition
      {
        geo_distance: {
          distance: (params[:within].presence || '100km' ),
          location: {
            lat: params[:latitude],
            lon: params[:longitude]
          },
        }
      }
    end
end
