class RoomRate < ApplicationRecord
  attr_accessor :calculated_price, :dynamic_price, :price_errors, :price_valid

  belongs_to :room_type, optional: true
  belongs_to :rate_plan
  belongs_to :child_lodging, class_name: 'Lodging'
  has_many :availabilities
  has_many :reservations
  has_many :prices, through: :availabilities
  has_one :parent_lodging, through: :child_lodging, source: :parent
  has_many :child_rates, through: :rate_plan

  enum default_single_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  enum extra_bed_rate_type: {
    fixed_rate: 0,
    percentage: 1
  }, _prefix: true

  delegate :code, :name, :pppn?, :papn?, :pp?, :ps?, :pppd?, :papd?, :opengds_pushed_at, to: :rate_plan, prefix: true, allow_nil: true
  delegate :open_gds_daily_supplements, :single_supplement?, :single_rate?, :min_stay, :max_stay, :open_gds_res_fee, :open_gds_rate_id, to: :rate_plan, allow_nil: true
  delegate :adults, :open_gds_accommodation_id, :extra_beds, :extra_beds_for_children_only, to: :child_lodging, allow_nil: true
  delegate :channel, to: :parent_lodging, prefix: true
  delegate :children, :infants, to: :child_rates, prefix: true, allow_nil: true
  delegate :name, :description, :crm_id, to: :child_lodging, prefix: true, allow_nil: true
  delegate :crm_id, to: :rate_plan, prefix: true, allow_nil: true
  delegate :name, :description, to: :child_lodging

  scope :include_lodgings_by_rate_plan, ->(lodging_ids, rate_plan_id) { where(child_lodging_id: lodging_ids, rate_plan_id: rate_plan_id) }
  scope :exclude_lodgings_by_rate_plan, ->(lodging_ids, rate_plan_id) { where.not(child_lodging_id: lodging_ids).where(rate_plan_id: rate_plan_id) }
  scope :lodging_channel, ->(channel) { joins(:parent_lodging).where(lodgings: { channel: channel }) }
  scope :published, -> { where(publish: true) }

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?)
      self.calculated_price = default_rate.to_f.round(2)
      return self.dynamic_price = false
    end

    prices = price_list(params.merge(flexible: false, rooms: params[:rooms] || 1))
    self.calculated_price = (prices[:rates].sum.round(2) * (params[:rooms] || 1).to_i)
    self.price_valid = prices[:valid]
    self.price_errors = prices[:errors]
    self.dynamic_price = true
  end

  def price_details(values)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], rooms: values[5] })
  end

  def minimum_booking_limit(params)
    return 0 unless params[:check_in].present? || params[:check_out].present?

    availabilities.for_range(params[:check_in], params[:check_out]).order(rr_booking_limit: :desc).minimum(:rr_booking_limit).presence || 0
  end

  private
    def price_list(params)
      return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless params[:check_in].present? && params[:check_out].present?

      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      if parent_lodging.open_gds?
        return OpenGds::SearchPriceWithDates.call(params.merge(room_rate_id: id, minimum_stay: total_nights, max_adults: adults.to_i, multiple_checkin_days: true), self)
      end

      SearchPriceWithFlexibleDates.call(params.merge(room_rate_id: id, minimum_stay: total_nights, max_adults: adults.to_i), nil, self)
    end
end
