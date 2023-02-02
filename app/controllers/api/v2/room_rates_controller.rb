class Api::V2::RoomRatesController < Api::V2::ApiController
  before_action :set_lodging
  before_action :set_room_rate

  def calendar_build
    params[:check_out] = (params[:check_in].to_date + 1.month).end_of_month
    @calendar_entries = ChannelManagers::CalendarBuild.call(room_rate: @room_rate, params: params)

    if @calendar_entries.present?
      render json: @calendar_entries, status: :ok
    else
      unprocessable_entity('No Available Days Found')
    end
  end

  def calendar_departure
    @calendar_entries = RoomRaccoons::CalendarDeparture.call(room_rate: @room_rate, params: params)

    if @calendar_entries.present?
      render json: @calendar_entries, status: :ok
    else
      unprocessable_entity('No Available Days Found')
    end
  end

  def cumulative_price
    @room_rate.cumulative_price(params.except(:lodging_id).clone)
    render json: Api::V2::RoomRateSerializer.new(@room_rate, { params: { check_in: params[:check_in], check_out: params[:check_out]}}).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def set_room_rate
      @room_rate = @lodging.room_rates.published.find(params[:id])
    end
end
