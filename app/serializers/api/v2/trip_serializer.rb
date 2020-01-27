class Api::V2::TripSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :adults, :children, :budget, :check_in, :check_out, :visibility

  attributes :trip_members do |trip|
    Api::V2::TripMemberSerializer.new(trip.trip_members)
  end

  attributes :lodgings do |trip|
    Api::V2::LodgingSerializer.new(trip.lodgings)
  end
end
