class Api::V2::PlacesController < Api::V2::ApiController
  before_action :set_lodging

  def index
    @places = SearchPlaces.call(params.merge(latitude: @lodging.latitude, longitude: @lodging.longitude))
    render json: { places: @places, categories: @places.collect(&:place_category).uniq }, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end
end
