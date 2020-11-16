class RatePlan < ApplicationRecord
  belongs_to :room_type
  has_many :prices
  has_many :cleaning_costs
end
