class Api::V2::ReviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :lodging_id, :reservation_id, :user_id, :description, :check_in, :average_stars, :title, :lodging_name, :lodging_slug

  attributes :user_full_name do |review|
    review.user_full_name unless review.anonymous?
  end
end
