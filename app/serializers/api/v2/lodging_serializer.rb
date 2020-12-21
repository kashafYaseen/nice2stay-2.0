class Api::V2::LodgingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :lodging_type, :slug, :presentation, :child_name, :country_name,
            :region_name, :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc, :including_text,
             :images, :thumbnails, :average_rating, :created_at, :updated_at, :highlight_1,
             :highlight_2, :highlight_3, :beds, :baths, :channel, :particularities_text

  attribute :cleaning_cost do |lodging, params|
    lodging.cleaning_cost_for((params[:adults].to_i + params[:children].to_i), params[:nights])
  end

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attribute :lowest_child_price do |lodging|
    lodging.lowest_child_price
  end

  attributes :amenities, if: Proc.new { |lodging, params| params.present? && params[:amenities].present? } do |lodging, params|
    Api::V2::AmenitySerializer.new(lodging.amenities.includes(:translations).uniq, params: { lodgings: params[:lodgings], total_lodgings: params[:total_lodgings] })
  end

  attributes :wishlist_id, if: Proc.new { |lodging, params| params.present? && params[:current_user].present? } do |lodging, params|
    lodging.wishlists.find_by(user: params[:current_user]).try(:id)
  end

  attributes :reviews, if: Proc.new { |lodging, params| params.present? && params[:reviews].present? } do |lodging, params|
    Api::V2::ReviewSerializer.new(lodging.all_reviews.limit(2))
  end
end
