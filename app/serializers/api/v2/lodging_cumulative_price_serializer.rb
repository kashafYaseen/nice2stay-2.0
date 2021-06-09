class Api::V2::LodgingCumulativePriceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :calculated_price, :price_valid, :price_errors

  attribute :cheapest_room_rate do |lodging, params|
    lodging.cheapest_room_rate(params)
  end
end
