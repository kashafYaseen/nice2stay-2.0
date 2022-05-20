class Api::V2::ReviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :lodging_id, :reservation_id, :user_id, :description, :check_in, :average_stars, :title, :lodging_name

  attributes :user_full_name do |review|
    review.user_full_name unless review.anonymous?
  end

  attribute :feedback_submitted, if: Proc.new { params.present? && params[:feedback_submitted].present? && params[:feedback_submitted] == true }
end
