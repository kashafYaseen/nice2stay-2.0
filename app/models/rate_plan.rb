class RatePlan < ApplicationRecord
  has_many :room_rates
  has_many :room_types, through: :room_rates
  has_many :availabilities, through: :room_rates
  has_many :reservations, through: :room_rates
  has_many :prices, through: :availabilities
  has_one :rule

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

  def price_details(values)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4] })
  end
end
