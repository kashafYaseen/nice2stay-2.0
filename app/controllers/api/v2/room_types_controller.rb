class Api::V2::RoomTypesController < Api::V2::ApiController
  before_action :set_lodging

  def cumulative_price
    room_types = @lodging.room_types.includes(room_rates: %i[parent_lodging rate_plan]).where(room_types: { id: ids })
    room_types.each do |room_type|
      room_type.room_rates.each do |room_rate|
        room_rate.cumulative_price(params.except(:lodging_id).clone)
      end
    end

    render json: Api::V2::RoomTypeSerializer.new(room_types).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def ids
      params[:ids].try(:split, ',')
    end
end
