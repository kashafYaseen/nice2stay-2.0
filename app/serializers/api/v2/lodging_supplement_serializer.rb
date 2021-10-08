class Api::V2::LodgingSupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name

  # attribute :optional_supplements, if: proc { |lodging| !lodging.belongs_to_channel? } do |lodging, params|
  #   supplements = lodging.as_standalone? ? lodging.supplements : lodging.linked_child_supplements
  #   Api::V2::SupplementSerializer.new(supplements.applied_lodgings_supplements(params[:check_in], params[:check_out], params[:adults].to_i, params[:children].to_i, ((lodging.as_standalone? && :lodging) || :linked_lodgings)).optional.published, params: params)
  # end

  attribute :mandatory_supplements, if: proc { |lodging| !lodging.belongs_to_channel? } do |lodging, params|
    supplements = lodging.as_standalone? ? lodging.supplements : lodging.linked_child_supplements
    Api::V2::SupplementSerializer.new(supplements.applied_lodgings_supplements(params[:check_in], params[:check_out], params[:adults].to_i, params[:children].to_i, ((lodging.as_standalone? && :lodging) || :linked_lodgings)).mandatory.published, params: params)
  end

  attribute :room_rates, if: proc { |lodging| lodging.belongs_to_channel? } do |lodging, params|
    Api::V2::RoomRateSupplementSerializer.new(lodging.room_rates.joins(:supplements), params: params.merge(lodging_adults: lodging.adults.to_i))
  end
end
