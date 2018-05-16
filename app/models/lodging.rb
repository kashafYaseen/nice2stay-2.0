class Lodging < ApplicationRecord
  has_many :reservations
  has_many :availabilities

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  after_create :add_lodging_availabilities
  mount_uploader :image, ImageUploader

  searchkick locations: [:location], text_start: [:city]

  enum lodging_type: {
    villa: 1,
    apartment: 2,
    bnb: 3,
  }

  def address
    [street, city, zip, state].compact.join(", ")
  end

  def address_changed?
    street_changed? || city_changed? || zip_changed? || state_changed?
  end

  def search_data
    attributes.merge(
      location: { lat: latitude, lon: longitude },
      available_on: availabilities.pluck(:available_on)
    )
  end

  private
    def add_lodging_availabilities
      Availability.bulk_insert do |availability|
        (Date.today..365.days.from_now).map(&:to_s).each do |date|
          availability.add(available_on: date, lodging_id: id, created_at: DateTime.now, updated_at: DateTime.now)
        end
      end

      Price.bulk_insert do |price|
        availabilities.each do |availability|
          price.add(amount: self.price, availability_id: availability.id, adults: adults, children: children, infants: infants, created_at: DateTime.now, updated_at: DateTime.now)
        end
      end
    end
end
