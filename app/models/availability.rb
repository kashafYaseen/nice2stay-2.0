class Availability < ApplicationRecord
  belongs_to :lodging, optional: true
  belongs_to :room_rate, optional: true
  has_one :rate_plan, through: :room_rate
  has_one :child_lodging, through: :room_rate
  has_one :parent_lodging, through: :room_rate
  has_many :prices
  has_many :cleaning_costs

  after_commit :reindex_lodging, if: -> (availability) { availability.lodging.present? }
  validates :available_on, uniqueness: { scope: :lodging }, if: -> (availability) { availability.lodging.present? }

  accepts_nested_attributes_for :prices, allow_destroy: true

  scope :with_in, -> (from, to) { where('available_on > ? and available_on < ?', from, to) }
  scope :for_range, -> (from, to) { where('available_on >= ? and available_on <= ?', from, to) }
  scope :check_out_only, -> { where(check_out_only: true) }
  scope :active, -> { where('available_on >= ?', Date.today) }
  scope :with_published_lodgings, -> { joins(:lodging).where("lodgings.published = true") }
  scope :with_published_room_rates, -> { joins(room_rate: [:child_lodging, :rate_plan]).where("room_rates.publish = true AND lodgings.published = true AND rate_plans.rate_enabled = true") }

  # for channel managers and opengds using booking limit
  scope :not_available, -> { active.having("SUM(rr_booking_limit) = 0").group(:available_on, :id) }

  def search_data
    attributes.merge(published: room_rate&.publish)
  end

  def reindex_lodging
    lodging.reindex
  end

  def self.check_out_only!(check_in)
    days = where(available_on: [check_in - 1.day, check_in]).order(available_on: :desc)
    return days.take.update_columns(check_out_only: true) if days.count == 2 && days.take.present?

    days.take.try(:delete)
  end

  def revert_out_only!(check_in)
    day = find_by(available_on: check_in - 1.day)
    day.update_columns(check_out_only: false) if day.present?
  end

  def self.not_available!(check_out)
    days = where(available_on: [check_out + 1.day, check_out]).order(:available_on)
    return if days.size == 2

    days.take.try(:delete)
  end

  def price_with(adults, children, amount, days)
    prices.find_by(adults: adults, children: children, amount: amount, minimum_stay: days)
  end

  def max_stay
    rr_minimum_stay.map(&:to_i).max
  end

  def min_stay
    rr_minimum_stay.map(&:to_i).min
  end
end
