class RoomRate < ApplicationRecord
  attr_accessor :calculated_price, :dynamic_price, :price_errors, :price_valid

  belongs_to :room_type
  belongs_to :rate_plan
  has_many :availabilities
  has_many :reservations

  enum default_single_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  enum extra_bed_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  delegate :code, to: :rate_plan, prefix: true, allow_nil: true
  delegate :adults, :parent_lodging, :open_gds_accommodation_id, to: :room_type, allow_nil: true

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

  private
    def price_list(params)
      return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless params[:check_in].present? && params[:check_out].present?
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      SearchPriceWithFlexibleDates.call(params.merge(rate_plan_id: id, minimum_stay: total_nights, max_adults: adults.to_i), nil, self)
    end
end
