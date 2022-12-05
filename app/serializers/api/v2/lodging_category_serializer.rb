class Api::V2::LodgingCategorySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name

  attribute :actual, if: Proc.new { |lodging_category, params| params.present? && params[:lodgings].present? } do |lodging_category, params|
    lodging_category.lodging_category_count_for(params[:lodgings])
  end

  attribute :total, if: Proc.new { |lodging_category, params| params.present? && params[:total_lodgings].present? } do |lodging_category, params|
    lodging_category.lodging_category_count_for(params[:total_lodgings])
  end
end
