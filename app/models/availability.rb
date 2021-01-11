class Availability < ApplicationRecord
  belongs_to :lodging, optional: true
  belongs_to :room_rate, optional: true
  has_one :rate_plan, through: :room_rate
  has_one :room_type, through: :room_rate
  has_many :prices
  has_many :cleaning_costs

  after_commit :reindex_lodging, if: -> (availability) { availability.lodging.present? }
  validates :available_on, uniqueness: { scope: :lodging }, if: -> (availability) { availability.lodging.present? }

  accepts_nested_attributes_for :prices, allow_destroy: true

  scope :with_in, -> (from, to) { where('available_on > ? and available_on < ?', from, to) }
  scope :for_range, -> (from, to) { where('available_on >= ? and available_on <= ?', from, to) }
  scope :check_out_only, -> { where(check_out_only: true) }
  scope :active, -> { where('available_on >= ?', Date.today) }

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
end
