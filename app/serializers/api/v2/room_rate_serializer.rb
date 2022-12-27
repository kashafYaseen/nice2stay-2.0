class Api::V2::RoomRateSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :default_rate, :calculated_price, :splited_rates, :dynamic_price, :price_valid, :price_errors, :default_booking_limit

  attribute :min_booking_limit, if: proc { |room_rate, params| params.present? && params[:check_in].present? && params[:check_out].present? } do |room_rate, params|
    room_rate.minimum_booking_limit(params)
  end

  attribute :rate_plan do |room_rate|
    Api::V2::RatePlanSerializer.new(room_rate.rate_plan)
  end
end
