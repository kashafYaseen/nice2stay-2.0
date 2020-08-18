class Api::V2::LodgingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :lodging_type, :presentation, :child_name, :address,
             :latitude, :longitude, :adults, :children, :infants, :country_name, :region_name,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc,
             :images, :thumbnails, :average_rating, :created_at, :updated_at, :highlight_1,
             :highlight_2, :highlight_3

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attribute :lowest_child_price do |lodging|
    lodging.lowest_child_price
  end

  attributes :amenities, if: Proc.new { |lodging, params| params.present? && params[:amenities].present? } do |lodging, params|
    Api::V2::AmenitySerializer.new(lodging.amenities.includes(:translations).uniq)
  end

  attributes :wishlist_id, if: Proc.new { |lodging, params| params.present? && params[:current_user].present? } do |lodging, params|
    lodging.wishlists.find_by(user: params[:current_user]).try(:id)
  end
end
