class Api::V2::ReviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :lodging_id, :reservation_id, :user_id, :description, :check_in, :average_stars, :title, :set_lodging_name, :set_lodging_slug

  attributes :user_full_name do |review|
    review.user_full_name unless review.anonymous?
  end
end
