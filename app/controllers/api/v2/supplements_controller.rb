class Api::V2::SupplementsController < Api::V2::ApiController
  before_action :set_lodging
  before_action :set_supplement, only: :show

  def index
    render json: Api::V2::LodgingSupplementSerializer.new(@lodging, params: { check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults].to_i, children: params[:children].to_i }).serialized_json, status: :ok
  end

  def show
    render json: Api::V2::SupplementSerializer.new(@supplement, params: { check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults].to_i, children: params[:children].to_i, quantity: params[:quantity] }).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.friendly.find(params[:lodging_id])
    end

    def set_supplement
      @supplement = @lodging.supplements.find(params[:id])
    end
end
