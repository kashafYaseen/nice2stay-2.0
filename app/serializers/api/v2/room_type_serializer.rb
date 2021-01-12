class Api::V2::RoomTypeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :code, :description, :adults, :children, :infants

  attributes :room_rates do |room_type|
    Api::V2::RoomRateSerializer.new(room_type.room_rates)
  end
end
