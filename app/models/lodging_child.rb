class LodgingChild < ApplicationRecord
  belongs_to :lodging
  has_many :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities

  after_create :add_availabilities
  after_create :reindex_prices

  def minimum_price
    prices.minimum(:amount)
  end

  def maximum_guests(type)
    prices.maximum(type).max
  end

  def minimum_guests(type)
    prices.minimum(type).min
  end

  def not_available_on
    (Date.today..2.years.from_now).map(&:to_s) - availabilities.pluck(:available_on).map(&:to_s)
  end

  private
    def add_availabilities
      Availability.bulk_insert do |availability|
        (Date.today..365.days.from_now).map(&:to_s).each do |date|
          availability.add(available_on: date, lodging_child_id: id, created_at: DateTime.now, updated_at: DateTime.now)
        end
      end
    end

    def reindex_prices
      prices.reindex
    end
end
