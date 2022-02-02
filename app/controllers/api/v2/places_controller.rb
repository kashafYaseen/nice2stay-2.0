class Api::V2::PlacesController < Api::V2::ApiController
  before_action :set_lodging

  def index
    @places = SearchPlaces.call(params.merge(latitude: @lodging.latitude, longitude: @lodging.longitude, country_id: @lodging.country.id))
    render json: {
      places: Api::V2::PlaceSerializer.new(@places, { params: { lodgings: @lodging } }).serializable_hash,
      categories: Api::V2::CategorySerializer.new(@places.collect(&:place_category).uniq).serializable_hash
    }, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end
end
