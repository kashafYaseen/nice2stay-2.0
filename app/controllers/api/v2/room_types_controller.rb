class Api::V2::RoomTypesController < Api::V2::ApiController
  before_action :set_lodging

  def cumulative_price
    _room_types = []

    room_types = @lodging.room_types.includes(:room_rates).where(room_types: { id: params[:ids].try(:split, ',') })
    room_types.each do |room_type|
      room_rates = []
      room_type.room_rates.each do |room_rate|
        room_rate.cumulative_price(params.except(:lodging_id).clone)
        room_rates << room_rate
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
