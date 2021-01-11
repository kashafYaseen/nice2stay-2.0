class RatePlan < ApplicationRecord
  serialize :open_gds_daily_supplements
  has_many :room_rates
  has_many :room_types, through: :room_rates
  has_many :availabilities, through: :room_rates
  has_many :reservations, through: :room_rates
  has_many :prices, through: :availabilities
  has_one :rule
  has_many :child_rates

  attr_accessor :calculated_price, :dynamic_price, :price_errors, :price_valid

  delegate :adults, :parent_lodging, :open_gds_accommodation_id, to: :room_type, allow_nil: true

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

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?)
      self.calculated_price = default_rate.to_f.round(2)
      return self.dynamic_price = false
    end

    prices = price_list(params.merge(flexible: false))
    self.calculated_price = prices[:rates].sum.round(2)
    self.price_valid = prices[:valid]
    self.price_errors = prices[:errors]
    self.dynamic_price = true
  end

  def price_details(values)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3],
                 infants: values[4] })
  end

  private

  def price_list(params)
    unless params[:check_in].present? && params[:check_out].present?
      return { rates: {}, search_params: params, valid: false,
               errors: { base: ['check_in & check_out dates must exist'] } }
    end

    total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
    SearchPriceWithFlexibleDates.call(
      params.merge(rate_plan_id: id, minimum_stay: total_nights, max_adults: adults.to_i), nil, self
    )
  end
end
