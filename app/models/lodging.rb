class Lodging < ApplicationRecord
  has_many :reservations
  has_many :availabilities

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
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
end
