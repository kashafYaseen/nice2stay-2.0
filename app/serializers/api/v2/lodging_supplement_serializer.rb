class Api::V2::LodgingSupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name

  attribute :supplements, if: proc { |lodging| !lodging.belongs_to_channel? } do |lodging, params|
    supplements = lodging.as_standalone? ? lodging.supplements : lodging.linked_child_supplements
    Api::V2::SupplementSerializer.new(supplements.applied_lodgings_supplements(params[:check_in], params[:check_out], params[:guests], ((lodging.as_standalone? && :lodging) || :linked_lodgings)), params: params)
  end

  attribute :room_rates, if: proc { |lodging| lodging.belongs_to_channel? } do |lodging, params|
    Api::V2::RoomRateSupplementSerializer.new(lodging.room_rates.joins(:supplements), params: params)
  end
end
