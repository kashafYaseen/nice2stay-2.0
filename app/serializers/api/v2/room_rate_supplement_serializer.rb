class Api::V2::RoomRateSupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id

  attributes :supplements, if: proc { |room_rate| room_rate.supplements.present? } do |room_rate, params|
    Api::V2::SupplementSerializer.new(room_rate.supplements.applied_room_rates_supplements(params[:check_in], params[:check_out], params[:adults], params[:children], params[:lodging_adults]).published, params: params)
  end
end
