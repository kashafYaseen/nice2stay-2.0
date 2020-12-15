class Api::V2::RoomTypesController < Api::V2::ApiController
  before_action :set_lodging

  def cumulative_price
    _room_types = []

    room_types = @lodging.room_types.includes(:rate_plans).where(room_types: { id: params[:ids].try(:split, ',') })
    room_types.each do |room_type|
      rate_plans = []
      room_type.rate_plans.each do |rate_plan|
        rate_plan.cumulative_price(params.except(:lodging_id).clone)
        rate_plans << rate_plan
      end
      _room_types << room_type
    end

    render json: Api::V2::RoomTypeSerializer.new(_room_types).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end
end
