class Api::V2::PlacesController < Api::V2::ApiController
  before_action :set_lodging

  def index
    @places = SearchPlaces.call(params.merge(latitude: @lodging.latitude, longitude: @lodging.longitude))
    render json: { data: @places.group_by(&:place_category).map{ |k, v| { category: {id: k.id, name: k.name}, places: v } } }, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end
end
