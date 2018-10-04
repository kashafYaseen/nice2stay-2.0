class Booking < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reservations

  scope :in_cart, -> { where(in_cart: true) }
end
