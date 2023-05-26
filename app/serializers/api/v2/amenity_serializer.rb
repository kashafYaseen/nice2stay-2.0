class Api::V2::AmenitySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :filter_enabled, :hot, :icon, :amenity_category_name, :image

  attribute :actual, if: Proc.new { |amenity, params| params.present? && params[:lodgings].present? } do |amenity, params|
    amenity.amenities_count_for(params[:lodgings])
  end

  attribute :total, if: Proc.new { |amenity, params| params.present? && params[:total_lodgings].present? } do |amenity, params|
    amenity.amenities_count_for(params[:total_lodgings])
  end
end
