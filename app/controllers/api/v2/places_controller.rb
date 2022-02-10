class Api::V2::PlacesController < Api::V2::ApiController
  before_action :set_lodging

  def index
    @places = SearchPlaces.call(common_params)
    @selected_places = SearchPlaces.call(common_params.merge(places_categories: @lodging.place_category_ids)) if @lodging.place_categories.present?
    render json: {
      places: Api::V2::PlaceSerializer.new(@places, { params: { lodging: @lodging } }).serializable_hash,
      selected_places: Api::V2::PlaceSerializer.new(@selected_places, { params: { lodging: @lodging } }).serializable_hash,
    }, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def common_params
      params.merge(latitude: @lodging.latitude, longitude: @lodging.longitude, country_id: @lodging.country.id)
    end
end
