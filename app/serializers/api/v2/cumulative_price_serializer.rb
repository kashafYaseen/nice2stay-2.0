class Api::V2::CumulativePriceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :calculated_price, :price_valid, :price_errors, :dynamic_price, :first_available_room

  attribute :belongs_to_channel do |lodging|
    lodging.belongs_to_channel?
  end

  attribute :available_rooms, if: proc { |lodging| lodging.as_parent? } do |lodging, params|
    check_in = params[:check_in] || (lodging.first_available_room && lodging.first_available_room[:check_in])
    check_out = params[:check_out] || (lodging.first_available_room && lodging.first_available_room[:check_out])
    lodging.available_rooms(params.clone.merge(check_in: check_in, check_out: check_out))
  end

  attributes :room_rates, if: proc { |lodging, params| lodging.belongs_to_channel? && !lodging.as_parent? } do |lodging, params|
    Api::V2::RoomRateSerializer.new(lodging.room_rates, { params: params })
  end
end
