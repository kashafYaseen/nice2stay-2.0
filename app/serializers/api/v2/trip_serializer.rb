class Api::V2::TripSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :adults, :children, :budget, :check_in, :check_out, :visibility, :need_advise

  attributes :trip_members do |trip|
    Api::V2::TripMemberSerializer.new(trip.trip_members)
  end

  attributes :lodgings, if: proc { |trip, params| params.dig(:lodgings_required) } do |trip|
    Api::V2::LodgingSerializer.new(trip.lodgings)
  end

  attributes :wishlists, if: proc { |trip, params| params.dig(:wishlists_required) } do |trip|
    Api::V2::WishlistSerializer.new(trip.wishlists)
  end
end
