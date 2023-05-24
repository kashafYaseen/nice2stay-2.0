class Api::V2::ExperienceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :tag, :slug, :short_desc, :image

  attribute :actual, if: Proc.new { |experience, params| params.present? && params[:lodgings].present? } do |experience, params|
    experience.experiences_count_for(params[:lodgings])
  end

  attribute :total, if: Proc.new { |experience, params| params.present? && params[:total_lodgings].present? } do |experience, params|
    experience.experiences_count_for(params[:total_lodgings])
  end
end
