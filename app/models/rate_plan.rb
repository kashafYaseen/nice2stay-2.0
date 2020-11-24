class RatePlan < ApplicationRecord
  belongs_to :room_type
  has_many :prices
  has_many :availabilities
  has_many :reservations
end
