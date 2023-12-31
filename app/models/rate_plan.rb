class RatePlan < ApplicationRecord
  serialize :open_gds_daily_supplements

  belongs_to :parent_lodging, class_name: 'Lodging'
  has_many :room_rates
  has_many :child_lodgings, through: :room_rates
  has_many :availabilities, through: :room_rates
  has_many :reservations, through: :room_rates
  has_many :prices, through: :availabilities
  has_one :rule
  has_many :child_rates
  has_many :cancellation_policies

  translates :name, :description
  globalize_accessors

  # validates_associated :room_rates
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

  accepts_nested_attributes_for :room_rates, allow_destroy: true, reject_if: :all_blank

  delegate :open_gds_arrival_days, to: :rule, allow_nil: true

  scope :active, -> { where.not(open_gds_rate_id: nil).order(:id) }

  def expired?
    return false if rule.blank?

    rule.end_date < Date.current
  end

  def final_payment_percentage
    100 - pre_payment_percentage.to_i
  end
end
