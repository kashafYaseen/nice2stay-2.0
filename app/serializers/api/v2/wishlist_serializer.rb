class Api::V2::WishlistSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :lodging_id, :created_at, :updated_at, :check_in, :check_out,
             :adults, :children, :notes, :status, :trip_id

  attributes :lodging do |wishlist|
    Api::V2::LodgingSerializer.new(wishlist.lodging)
  end
end
