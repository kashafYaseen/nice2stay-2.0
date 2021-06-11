class Api::V2::CumulativePriceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :calculated_price, :price_valid, :price_errors, :dynamic_price, :cheapest_available_room

  attribute :belongs_to_channel do |lodging|
    lodging.belongs_to_channel?
  end

  attributes :room_rates, if: proc { |lodging, params| lodging.belongs_to_channel? && !lodging.as_parent? } do |lodging, params|
    Api::V2::RoomRateSerializer.new(lodging.room_rates, { params: params })
  end
end
