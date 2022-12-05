class Api::V2::VisitedLodgingsController < Api::V2::ApiController
  before_action :authenticate

  def index
    render json: Api::V2::LodgingSerializer.new(current_user.visited_lodgings).serialized_json, status: :ok
  end

  def create
    lodging = Lodging.find(params[:lodging_id])
    visited_lodgings = current_user.visited_lodgings
    visited_lodgings << lodging unless visited_lodgings.include? lodging
    render json: { message: 'success'}, status: :created
  end

  def destroy
    current_user.visited_lodgings.destroy_all
    head :no_content
  end
end
