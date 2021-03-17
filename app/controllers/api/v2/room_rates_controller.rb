class Api::V2::RoomRatesController < Api::V2::ApiController
  before_action :set_lodging
  before_action :set_room_rate

  def cumulative_price
    @room_rate.cumulative_price(params.except(:lodging_id).clone)
    render json: Api::V2::RoomRateSerializer.new(@room_rate).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def set_room_rate
      @room_rate = @lodging.room_rates.find(params[:id])
    end
end
