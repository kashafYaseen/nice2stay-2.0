class Api::V2::LodgingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :lodging_type, :slug, :presentation, :child_name, :country_name,
            :region_name, :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc, :including_text,
             :images, :thumbnails, :average_rating, :created_at, :updated_at, :highlight_1,
             :highlight_2, :highlight_3, :beds, :baths, :channel, :particularities_text,
             :open_gds_property_id, :open_gds_accommodation_id

  attribute :cleaning_cost do |lodging, params|
    lodging.cleaning_cost_for((params[:adults].to_i + params[:children].to_i), params[:nights])
  end

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attribute :lowest_child_price do |lodging|
    lodging.lowest_child_price
  end

  attributes :wishlist_id, if: Proc.new { |lodging, params| params.present? && params[:current_user].present? } do |lodging, params|
    lodging.wishlists.find_by(user: params[:current_user]).try(:id)
  end

  attributes :room_rates, if: proc { |lodging, params| lodging.belongs_to_channel? && !lodging.as_parent? } do |lodging, params|
    Api::V2::RoomRateSerializer.new(lodging.room_rates, { params: params })
  end

  attribute :cheapest_room_rate, if: proc { |lodging| lodging.belongs_to_channel? && lodging.as_parent? } do |lodging, params|
    Api::V2::RoomRateSerializer.new(lodging.cheapest_room_rate(params), { params: params })
  end
end
