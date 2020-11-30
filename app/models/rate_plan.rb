class RatePlan < ApplicationRecord
  belongs_to :room_type
  has_many :availabilities
  has_many :prices, through: :availabilities
  has_many :reservations
end
