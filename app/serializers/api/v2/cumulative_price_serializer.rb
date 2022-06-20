class Api::V2::CumulativePriceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :calculated_price, :price_valid, :price_errors, :dynamic_price, :check_in, :check_out, :discount_price, :rent_price, :cleaning_cost

  attribute :belongs_to_channel do |lodging|
    lodging.belongs_to_channel?
  end

  attributes :room_rates, if: proc { |lodging, params| lodging.belongs_to_channel? && !params[:accom_listing] } do |lodging, params|
    Api::V2::RoomRateSerializer.new(lodging.room_rates.select { |room_rate| room_rate.publish && room_rate.rate_enabled }, { params: params })
  end

  attribute :optional_supplements, if: proc { |lodging, params| !lodging.belongs_to_channel? && params[:show_supplements] } do |lodging, params|
    supplements = lodging.as_standalone? ? lodging.supplements : lodging.linked_child_supplements
    Api::V2::SupplementSerializer.new(supplements.applied_lodgings_supplements(params[:check_in], params[:check_out], params[:adults].to_i, params[:children].to_i, ((lodging.as_standalone? && :lodging) || :linked_lodgings)).optional.published, params: params)
  end

  attribute :mandatory_supplements, if: proc { |lodging, params| !lodging.belongs_to_channel? && params[:show_supplements] } do |lodging, params|
    supplements = lodging.as_standalone? ? lodging.supplements : lodging.linked_child_supplements
    Api::V2::SupplementSerializer.new(supplements.applied_lodgings_supplements(params[:check_in], params[:check_out], params[:adults].to_i, params[:children].to_i, ((lodging.as_standalone? && :lodging) || :linked_lodgings)).mandatory.published, params: params)
  end
end
