class Lodging < ApplicationRecord
  belongs_to :owner
  belongs_to :region
  has_many :lodging_children
  has_many :reservations, through: :lodging_children
  has_many :availabilities, through: :lodging_children
  has_many :prices, through: :lodging_children
  has_many :rules
  has_many :discounts
  has_many :reviews
  has_many :specifications

  attr_accessor :check_in_day

  geocoded_by :address
  after_validation :geocode, if: :address_changed?
  after_create :create_child

  searchkick locations: [:location], word_start: [:city]

  accepts_nested_attributes_for :availabilities, allow_destroy: true
  accepts_nested_attributes_for :rules, allow_destroy: true
  accepts_nested_attributes_for :discounts, allow_destroy: true
  accepts_nested_attributes_for :specifications, allow_destroy: true
  accepts_nested_attributes_for :reviews, allow_destroy: true

  delegate :active, to: :rules, allow_nil: true, prefix: true
  delegate :active, to: :discounts, allow_nil: true, prefix: true
  delegate :full_name, :image_url, to: :owner, allow_nil: true, prefix: true
  delegate :country, to: :region, allow_nil: true
  delegate :with_in, to: :availabilities, allow_nil: true, prefix: true

  translates :title, :subtitle, :description

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
      country: country.name,
      region: region.name,
      available_on: availabilities.pluck(:available_on),
      availability_price: prices.pluck(:amount),
      availability_adults: prices.pluck(:adults),
      availability_children: prices.pluck(:children),
      availability_infants: prices.pluck(:infants)
    )
  end

  def price_details(values)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], lodging_child_id: values[5] })
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

  def truncated_description
    return unless description.present?
    return description.truncate(600) if truncate_description?
    description
  end

  def truncate_description?
    return false unless description.present?
    description.split(' ').length > 600
  end

  def child
    lodging_children.first_or_create(title: "#{name} #1")
  end

  private
    def price_list(params)
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      price_list = SearchPrices.call(params.merge(lodging_id: id, minimum_stay: total_nights)).collect(&:day_price)
      price_list = price_list + [price] * (total_nights - price_list.size) if price_list.size < total_nights
      price_list
    end

    def discount(params)
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      discount = discounts_active.where('reservation_days <= ?', total_nights).order(:reservation_days).last
      discount.discount_percentage if discount.present?
    end

    def create_child
      return if lodging_children.present?
      lodging_children.create(title: "#{name} #1")
    end
end
