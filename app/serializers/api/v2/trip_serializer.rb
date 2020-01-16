class Api::V2::TripSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :adults, :children, :budget, :check_in, :check_out, :visibility

  attributes :users do |trip|
    Api::V2::UserSerializer.new(trip.users)
  end

  attributes :lodgings do |trip|
    Api::V2::LodgingSerializer.new(trip.lodgings)
  end
end
