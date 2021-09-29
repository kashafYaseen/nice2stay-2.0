class Api::V2::SupplementsController < Api::V2::ApiController
  before_action :set_lodging

  def index
    render json: Api::V2::LodgingSupplementSerializer.new(@lodging, params: { check_in: params[:check_in], check_out: params[:check_out], guests: params[:guests] }).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.friendly.find(params[:lodging_id])
    end
end
