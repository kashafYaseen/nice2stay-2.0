class LodgingChild < ApplicationRecord
  belongs_to :lodging
  has_many :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities

  after_create :add_availabilities_and_prices
  after_create :reindex_prices

  private
    def add_availabilities_and_prices
      Availability.bulk_insert do |availability|
        (Date.today..365.days.from_now).map(&:to_s).each do |date|
          availability.add(available_on: date, lodging_child_id: id, created_at: DateTime.now, updated_at: DateTime.now)
        end
      end

      Price.bulk_insert do |price|
        availabilities.each do |availability|
          price.add(amount: lodging.price, availability_id: availability.id, adults: adults, children: children, infants: infants, created_at: DateTime.now, updated_at: DateTime.now)
        end
      end
    end

    def reindex_prices
      prices.reindex
    end
end
