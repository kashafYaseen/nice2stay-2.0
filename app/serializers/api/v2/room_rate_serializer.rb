class Api::V2::RoomRateSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :default_rate, :calculated_price, :dynamic_price, :price_valid, :price_errors, :default_booking_limit

  attribute :rate_plan do |room_rate|
    Api::V2::RatePlanSerializer.new(room_rate.rate_plan)
  end
end
