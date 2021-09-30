class Api::V2::RoomRateSupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id

  attributes :supplements do |room_rate, params|
    Api::V2::SupplementSerializer.new(room_rate.supplements.applied_room_rates_supplements(params[:check_in], params[:check_out], params[:guests]), params: params)
  end
end
