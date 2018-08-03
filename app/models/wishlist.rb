class Wishlist < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lodging

  delegate :slug, :name, :image, to: :lodging, prefix: true, allow_nil: true
end
