class Lodging < ApplicationRecord
  has_many :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  after_create :add_lodging_availabilities
  mount_uploader :image, ImageUploader

  searchkick locations: [:location], text_start: [:city]

  accepts_nested_attributes_for :availabilities, allow_destroy: true

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
      available_on: availabilities.pluck(:available_on),
      availability_price: prices.pluck(:amount),
      availability_adults: prices.pluck(:adults),
      availability_children: prices.pluck(:children),
      availability_infants: prices.pluck(:infants)
    )
  end

  def minimum_price
    prices.minimum(:amount)
  end

  def maximum_guests(type)
    prices.maximum(type)
  end

  def minimum_guests(type)
    prices.minimum(type)
  end

  def not_available_on
    (2.years.ago.to_date..2.years.from_now).map(&:to_s) - availabilities.pluck(:available_on).map(&:to_s)
  end

  def price_details(values)
    check_in, check_out = values[0], (values[1].to_date - 1.day).to_s
    total_nights = (check_out.to_date - check_in.to_date).to_i + 1
    price_list = prices.joins(:availability).where(availabilities: { available_on: (check_in..check_out).map(&:to_s) }, adults: values[2], children: values[3], infants: values[4]).pluck(:amount)
    price_list = price_list + [price] * (total_nights - price_list.size) if price_list.size < total_nights
    price_list
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
