class Wishlist < ApplicationRecord
  belongs_to :user
  belongs_to :lodging
end
