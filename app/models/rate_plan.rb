class RatePlan < ApplicationRecord
  serialize :open_gds_daily_supplements
  has_many :room_rates
  has_many :room_types, through: :room_rates
  has_many :availabilities, through: :room_rates
  has_many :reservations, through: :room_rates
  has_many :prices, through: :availabilities
  has_one :rule
  has_many :child_rates

  enum open_gds_rate_type: {
    pppn: 0,
    papn: 1,
    pp: 2,
    ps: 3,
    pppd: 4,
    papd: 5
  }

  enum open_gds_single_rate_type: {
    single_supplement: 0,
    single_rate: 1
  }
end
