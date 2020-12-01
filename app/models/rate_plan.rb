class RatePlan < ApplicationRecord
  belongs_to :room_type
  has_many :availabilities
  has_many :prices, through: :availabilities
  has_many :reservations

  attr_accessor :calculated_price
  attr_accessor :dynamic_price

  delegate :adults, :parent_lodging, to: :room_type

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?)
      self.calculated_price = default_rate.to_f.round(2)
      return self.dynamic_price = false
    end

    total_price = price_list(params.merge(flexible: false))[:rates].sum
    self.calculated_price = total_price.round(2)
    self.dynamic_price = true
  end

  def price_list(params)
    return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless params[:check_in].present? && params[:check_out].present?
    total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
    SearchPriceWithFlexibleDates.call(params.merge(rate_plan_id: id, minimum_stay: total_nights, max_adults: adults.to_i), nil, self)
  end
end
