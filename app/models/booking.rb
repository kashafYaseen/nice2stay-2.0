class Booking < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reservations

  scope :in_cart, -> { where(in_cart: true) }

  accepts_nested_attributes_for :reservations
  accepts_nested_attributes_for :user
end
