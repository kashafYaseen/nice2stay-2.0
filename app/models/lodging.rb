class Lodging < ApplicationRecord
  has_many :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities
  has_many :rules
  has_many :discounts
  has_many :reviews
  has_many :specifications

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  after_create :add_lodging_availabilities
  after_create :reindex_prices
  mount_uploader :image, ImageUploader

  searchkick locations: [:location], word_start: [:city]

  accepts_nested_attributes_for :availabilities, allow_destroy: true
  accepts_nested_attributes_for :rules, allow_destroy: true
  accepts_nested_attributes_for :discounts, allow_destroy: true

  delegate :active, to: :rules, allow_nil: true, prefix: true
  delegate :active, to: :discounts, allow_nil: true, prefix: true

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
    (Date.today..2.years.from_now).map(&:to_s) - availabilities.pluck(:available_on).map(&:to_s)
  end

  def price_details(values)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], lodging_id: id })
  end

  def discount_details(values)
    discount({ check_in: values[0], check_out: values[1] })
  end

  def cumulative_price(params)
    return "$#{price} per night" unless params.values_at(:check_in, :check_out, :adults, :children, :infants).all?(&:present?)
    total_price = price_list(params).sum
    total_discount = discount(params)
    total_price -= total_price * (total_discount/100) if total_discount.present?
    "$#{total_price} for #{(params[:check_out].to_date - params[:check_in].to_date).to_i} nights"
  end

  def allow_check_in_days
    days = rules_active(Date.today,Date.today).pluck(:check_in_days).join(',')
    days.present? ? days : "All days"
  end

  def allow_days_multipliers
    days = rules_active(Date.today,Date.today).pluck(:days_multiplier).join(',')
    days.present? ? days : "All numbers"
  end

  def avg_rating
    return 0.0 unless reviews.present?
    reviews.average(:stars).round(2)
  end

  def rating_for(stars)
    reviews.where(stars: stars).count
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

    def price_list(params)
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      price_list = SearchPrices.call(params.merge(lodging_id: id)).pluck(:amount)
      price_list = price_list + [price] * (total_nights - price_list.size) if price_list.size < total_nights
      price_list
    end

    def reindex_prices
      prices.reindex
    end

    def discount(params)
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      discount = discounts_active.where('reservation_days <= ?', total_nights).order(:reservation_days).last
      discount.discount_percentage if discount.present?
    end
end
