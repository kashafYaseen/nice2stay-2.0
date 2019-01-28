class Lodging < ApplicationRecord
  belongs_to :owner
  belongs_to :region
  has_many :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities
  has_many :rules
  has_many :discounts
  has_many :reviews
  has_many :specifications
  has_many :wishlists
  has_many :cleaning_costs
  has_one :price_text
  has_and_belongs_to_many :amenities, join_table: 'lodgings_amenities'
  has_and_belongs_to_many :experiences, join_table: 'lodgings_experiences'

  belongs_to :parent, class_name: 'Lodging', optional: true
  has_many :lodging_children, class_name: 'Lodging', foreign_key: :parent_id

  include ImageHelper

  attr_accessor :flexible_search
  attr_accessor :calculated_price
  attr_accessor :dynamic_price

  geocoded_by :address
  after_validation :geocode, if: :address_changed?


  extend FriendlyId
  friendly_id :name, use: :slugged

  accepts_nested_attributes_for :availabilities, allow_destroy: true
  accepts_nested_attributes_for :rules, allow_destroy: true
  accepts_nested_attributes_for :discounts, allow_destroy: true
  accepts_nested_attributes_for :specifications, allow_destroy: true
  accepts_nested_attributes_for :reviews, allow_destroy: true

  delegate :active, to: :rules, allow_nil: true, prefix: true
  delegate :active, to: :discounts, allow_nil: true, prefix: true
  delegate :full_name, :image_url, to: :owner, allow_nil: true, prefix: true
  delegate :country, to: :region, allow_nil: true
  delegate :with_in, :for_range, to: :availabilities, allow_nil: true, prefix: true
  delegate :desc, :published, to: :reviews, allow_nil: true, prefix: true
  delegate :including_text, :particularities_text, :pay_text, :options_text, :payment_terms_text, to: :price_text, allow_nil: true

  scope :published, -> { where(published: true) }
  scope :searchable, -> { where('presentation = ? or presentation = ?', 1, 2) }
  scope :home_page, -> { published.where(home_page: true) }
  scope :region_page, -> { published.where(region_page: true) }
  scope :country_page, -> { published.where(country_page: true) }
  scope :search_import, -> { includes({ amenities: :translations }, { experiences: :translations }, :availabilities, :rules) }

  translates :title, :subtitle, :description, :meta_desc, :slug, :h1, :h2, :h3, :highlight_1, :highlight_2, :highlight_3, :summary, :short_desc, :location_description

  enum lodging_type: {
    villa: 1,
    apartment: 2,
    bnb: 3,
  }

  enum presentation: {
    as_parent: 1,
    as_standalone: 2,
    as_child: 3,
  }

  after_create :add_availabilities
  after_create :reindex_prices

  def not_available_on
    (Date.today..2.years.from_now).map(&:to_s) - availabilities.pluck(:available_on).map(&:to_s)
  end

  def children_not_available_on
    return not_available_on unless lodging_children.present?
    _availabilities = []
    lodging_children.includes(:availabilities).each do |lodging_child|
      _availabilities += lodging_child.availabilities.pluck(:available_on).map(&:to_s)
    end
    (Date.today..2.years.from_now).map(&:to_s) - _availabilities
  end

  def address
    [street, city, zip, state].compact.join(", ")
  end

  def address_changed?
    street_changed? || city_changed? || zip_changed? || state_changed?
  end

  searchkick batch_size: 200, locations: [:location], text_middle: [:name], merge_mappings: true, mappings: {
    lodging: {
      properties: {
        rules: { type: :nested }
      }
    }
  }

  def search_data
    attributes.merge(
      location: { lat: latitude, lon: longitude },
      country: country.translated_slugs,
      region: region.translated_slugs,
      extended_name: extended_name,
      available_on: availabilities.pluck(:available_on),
      availability_price: availability_price,
      adults_and_children: adults_plus_children,
      amenities: amenities.collect(&:name),
      amenities_ids: amenities.ids,
      experiences: experiences.collect(&:translated_slugs),
      experiences_ids: experiences.ids,
      rules: rules.collect(&:search_data),
    )
  end

  def availability_price
    prices.pluck(:amount).presence || [price]
  end

  def adults_plus_children
    adults.to_i + children.to_i
  end

  def price_details(values, flexible = true)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], flexible: flexible })
  end

  def discount_details(values)
    discount({ check_in: values[0], check_out: values[1] })
  end

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?)
      self.calculated_price = price.round(2)
      return self.dynamic_price = false
    end
    total_price = price_list(params.merge(flexible: false))[:rates].sum
    total_discount = discount(params)
    total_price -= total_price * (total_discount/100) if total_discount.present?
    self.calculated_price = total_price.round(2)
    self.dynamic_price = true
  end

  def allow_check_in_days
    days = rules_active(Date.today,Date.today).pluck(:check_in_days).join(',')
    days.present? ? days : "All days"
  end

  def allow_days_multipliers
    days = rules_active(Date.today,Date.today).pluck(:days_multiplier).join(',')
    days.present? ? days : "All numbers"
  end

  def total_prices
    prices.count
  end

  def total_rules
    rules.count
  end

  def child_name
    return unless as_child? && name.include?('-')
    name.split('-').last.strip
  end

  def flexible_search
    @flexible_search || false
  end

  def extended_name
    "#{name} - #{lodging_type} - #{country.name} #{region.name}"
  end

  def all_reviews
    return reviews_published.desc unless as_parent?
    Review.published.where(lodging_id: lodging_children.ids.push(id)).includes(:translations).desc
  end

  def update_ratings
    _reviews = all_reviews
    return unless _reviews.present?
    total = _reviews.count

    update_attributes(
      setting: _reviews.rating_sum(:setting)/total,
      quality: _reviews.rating_sum(:quality)/total,
      interior: _reviews.rating_sum(:interior)/total,
      service: _reviews.rating_sum(:service)/total,
      communication: _reviews.rating_sum(:communication)/total,
      average_rating: _reviews.ratings_average,
    )
  end

  def add_availabilities_for dates
    Availability.bulk_insert do |availability|
      dates.each do |date|
        availability.add(available_on: date, lodging_id: id, created_at: DateTime.now, updated_at: DateTime.now)
      end
    end
  end

  private
    def add_availabilities
      Availability.bulk_insert do |availability|
        (Date.today..365.days.from_now).map(&:to_s).each do |date|
          availability.add(available_on: date, lodging_id: id, created_at: DateTime.now, updated_at: DateTime.now)
        end
      end
    end

    def price_list(params)
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      SearchPriceWithFlexibleDates.call(params.merge(lodging_id: id, minimum_stay: total_nights, max_adults: adults.to_i), self)
    end

    def discount(params)
      total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
      discount = discounts_active.where('reservation_days <= ?', total_nights).order(:reservation_days).last
      discount.discount_percentage if discount.present?
    end

    def reindex_prices
      prices.reindex
    end
end
