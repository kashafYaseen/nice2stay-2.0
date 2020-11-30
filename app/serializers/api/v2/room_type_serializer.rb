class Api::V2::RoomTypeSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :code, :description

  attributes :rate_plans do |room_type|
    Api::V2::RatePlanSerializer.new(room_type.rate_plans)
  end
end
