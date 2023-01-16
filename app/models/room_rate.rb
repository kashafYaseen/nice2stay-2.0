class RoomRate < ApplicationRecord
  attr_accessor :calculated_price, :splited_rates, :dynamic_price, :price_errors, :price_valid, :check_in, :check_out

  belongs_to :rate_plan
  belongs_to :child_lodging, class_name: 'Lodging'
  has_one :rule, through: :rate_plan
  has_one :parent_lodging, through: :child_lodging, source: :parent
  has_many :availabilities
  has_many :reservations
  has_many :prices, through: :availabilities
  has_many :child_rates, through: :rate_plan
  has_many :linked_supplements, as: :supplementable
  has_many :supplements, through: :linked_supplements

  enum default_single_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  enum extra_bed_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  delegate :code, :name, :pppn?, :papn?, :pp?, :ps?, :pppd?, :papd?, :opengds_pushed_at, to: :rate_plan, prefix: true, allow_nil: true
  delegate :open_gds_daily_supplements, :single_supplement?, :single_rate?, :min_stay, :max_stay, :open_gds_res_fee, :open_gds_rate_id, :rate_enabled, to: :rate_plan, allow_nil: true
  delegate :adults, :open_gds_accommodation_id, :extra_beds, :extra_beds_for_children_only, to: :child_lodging, allow_nil: true
  delegate :channel, to: :parent_lodging, prefix: true
  delegate :children, :infants, to: :child_rates, prefix: true, allow_nil: true
  delegate :name, :description, :crm_id, to: :child_lodging, prefix: true, allow_nil: true
  delegate :crm_id, :expired?, to: :rate_plan, prefix: true, allow_nil: true
  delegate :name, :description, :open_gds?, :room_raccoon?, :channel, to: :child_lodging

  scope :include_lodgings_by_rate_plan, ->(lodging_ids, rate_plan_id) { where(child_lodging_id: lodging_ids, rate_plan_id: rate_plan_id) }
  scope :exclude_lodgings_by_rate_plan, ->(lodging_ids, rate_plan_id) { where.not(child_lodging_id: lodging_ids).where(rate_plan_id: rate_plan_id) }
  scope :lodging_channel, ->(channel) { joins(:parent_lodging).where(lodgings: { channel: channel }) }
  scope :published, -> { where(publish: true) }
  scope :with_active_rate_plan, -> { joins(:rate_plan).where(rate_plans: { rate_enabled: true }).order("rate_plans.id") }

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?) || params.values_at(:months, :adults, :children).all?(&:present?)
      self.calculated_price = default_rate.to_f.round(2)
      return self.dynamic_price = false
    end

    prices = price_list(params.merge(rooms: params[:rooms] || 1))
    self.calculated_price = (prices[:rates].sum.round(2) * (params[:rooms] || 1).to_i)
    self.splited_rates = prices[:splited_rates_info].to_h.reject! { |key| key == :price }
    self.price_valid = prices[:valid]
    self.price_errors = prices[:errors]
    self.dynamic_price = true
    self.check_in = prices[:check_in]
    self.check_out = prices[:check_out]
  end

  def search_data
    _rule = rule
    attributes.merge(
      availabilities: availabilities.active.collect { |availability| availability.search_data.merge(open_gds_restriction_type: _rule.try(:open_gds_restriction_type), open_gds_restriction_days: _rule.try(:open_gds_restriction_days), open_gds_arrival_days: _rule.try(:open_gds_arrival_days)) },
      _rule_present: _rule.present?,
      rate_enabled: rate_plan.rate_enabled
    )
  end

  def price_details(values:, daily_rate: false, calendar_departure: false)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], rooms: values[5], daily_rate: daily_rate, calendar_departure: calendar_departure })
  end

  def minimum_booking_limit(params)
    return 0 unless params[:check_in].present? || params[:check_out].present?
    availabilities.for_range(params[:check_in], params[:check_out]).order(booking_limit: :desc).minimum(:booking_limit).presence || 0
  end

  private
    def price_list(params)
      return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless params[:check_in].present? && params[:check_out].present? || params[:months].present?
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i if params[:check_in].present? && params[:check_out].present?
      SearchPriceWithFlexibleDates.call(params.merge(room_rate_id: id, minimum_stay: (total_nights || params[:minimum_stay]).to_i, max_adults: adults.to_i, multiple_checkin_days: open_gds?), nil, self)
    end
end
