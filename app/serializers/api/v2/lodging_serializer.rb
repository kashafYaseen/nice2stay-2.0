class Api::V2::LodgingSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :h1, :h2, :lodging_type, :presentation,
             :address, :latitude, :longitude, :adults, :children, :infants,
             :price, :calculated_price, :dynamic_price, :summary, :description, :short_desc,
             :images, :thumbnails, :average_rating, :created_at, :updated_at

  attribute :total_reviews do |lodging|
    lodging.all_reviews.count
  end

  attributes :rooms, if: Proc.new { |lodging, params| params.present? && params[:rooms].present? } do |lodging, params|
    Api::V2::LodgingSerializer.new(lodging.lodging_children) if lodging.as_parent?
  end
end
