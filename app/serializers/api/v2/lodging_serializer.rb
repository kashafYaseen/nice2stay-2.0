class Api::V2::LodgingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :lodging_type, :slug, :presentation, :child_name, :country_name,
             :region_name, :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :short_desc,
             :images, :average_rating, :created_at, :updated_at, :highlight_1,
             :highlight_2, :highlight_3, :beds, :baths, :channel, :particularities_text,
             :open_gds_property_id, :open_gds_accommodation_id, :including_text,
             :setting, :quality, :interior, :service, :communication

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attribute :lowest_child_price do |lodging|
    (lodging.as_standalone? && lodging.price) || lodging.lowest_child_price
  end

  attributes :wishlist_id, if: proc { |lodging, params| params.present? && params[:current_user].present? } do |lodging, params|
    lodging.wishlists.find_by(user: params[:current_user]).try(:id)
  end

  attribute :total_available_childrens, if: proc { |lodging, params| params.present? } do |lodging, params|
    lodging.available_children_wrt(params[:lodgings])
  end

  attribute :first_available_child_id, if: proc { |lodging, params| params.present? } do |lodging, params|
    lodging.first_available_child_wrt(params[:lodgings])
  end
end
