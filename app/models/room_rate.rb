class RoomRate < ApplicationRecord
  attr_accessor :calculated_price, :dynamic_price, :price_errors, :price_valid

  belongs_to :room_type
  belongs_to :rate_plan
  has_many :availabilities
  has_many :reservations
  has_many :prices, through: :availabilities
  has_one :parent_lodging, through: :room_type
  has_many :child_rates, through: :rate_plan

  validates :room_type, uniqueness: { scope: :rate_plan }

  enum default_single_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  enum extra_bed_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  delegate :code, :name, :pppn?, :papn?, :pp?, :ps?, :pppd?, :papd?, to: :rate_plan, prefix: true, allow_nil: true
  delegate :open_gds_daily_supplements, :single_supplement?, :single_rate?, :min_stay, :open_gds_res_fee, to: :rate_plan, allow_nil: true
  delegate :adults, :open_gds_accommodation_id, :extra_beds, :extra_beds_for_children_only, to: :room_type, allow_nil: true
  delegate :code, :name, :description, to: :room_type, prefix: true, allow_nil: true
  delegate :channel, to: :parent_lodging, prefix: true
  delegate :children, to: :child_rates, prefix: true, allow_nil: true

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
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4] })
  end

  private
    def price_list(params)
      return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless params[:check_in].present? && params[:check_out].present?

      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      return OpenGds::SearchPriceWithDates.call(params.merge(room_rate_id: id, minimum_stay: total_nights, max_adults: adults.to_i, multiple_checkin_days: true), self) if parent_lodging.open_gds?

      SearchPriceWithFlexibleDates.call(params.merge(room_rate_id: id, minimum_stay: total_nights, max_adults: adults.to_i), nil, self)
    end
end
