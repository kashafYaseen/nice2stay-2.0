class Lodging < ApplicationRecord
  belongs_to :owner, optional: true
  belongs_to :region
  has_many :reservations
  has_many :users, through: :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities
  has_many :rules
  has_many :discounts
  has_many :reviews
  has_many :specifications
  has_many :wishlists
  has_many :cleaning_costs
  has_many :places, through: :region
  has_many :gc_offers
  has_many :recent_searches, as: :searchable
  has_one :price_text
  has_and_belongs_to_many :amenities, join_table: 'lodgings_amenities'
  has_and_belongs_to_many :experiences, join_table: 'lodgings_experiences'
  has_and_belongs_to_many :visited_users, class_name: 'User', join_table: 'visited_lodgings'

  belongs_to :parent, class_name: 'Lodging', optional: true
  has_many :room_types, foreign_key: :parent_lodging_id
  belongs_to :room_type, optional: true
  has_many :lodging_children, class_name: 'Lodging', foreign_key: :parent_id
  has_many :rate_plans, through: :room_types
  has_many :room_rate_plans, through: :room_type, source: :rate_plans

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
  delegate :name, to: :region, allow_nil: true, prefix: true
  delegate :name, to: :country, allow_nil: true, prefix: true
  delegate :with_in, :for_range, to: :availabilities, allow_nil: true, prefix: true
  delegate :desc, :published, to: :reviews, allow_nil: true, prefix: true
  delegate :including_text, :particularities_text, :pay_text, :options_text, :payment_terms_text, :deposit_text, to: :price_text, allow_nil: true
  delegate :admin_user, to: :owner, allow_nil: true
  delegate :summary, :location_description, :h1, to: :parent, allow_nil: true, prefix: true
  delegate :code, :description, to: :room_type, prefix: true

  scope :published, -> { where(published: true) }
  scope :searchable, -> { where('presentation = ? or presentation = ?', 1, 2) }
  scope :home_page, -> { published.where(home_page: true) }
  scope :region_page, -> { published.where(region_page: true) }
  scope :country_page, -> { published.where(country_page: true) }
  scope :guest_centric, -> { published.where(guest_centric: true) }
  scope :search_import, -> { published.includes({ amenities: :translations }, { experiences: :translations }, :availabilities, :rules) }
  scope :country_id_eq, -> (country) { joins(:region).where(regions: { country_id: country }) }
  scope :published_parents_count, -> { as_parent.published.count }
  scope :by_rate_code, ->(rate_plan_code) { joins(:prices).where("prices.rr_rate_plan_code = ?", rate_plan_code) }
  scope :parent_lodgings, -> { where(parent_id: nil) }
  scope :new_lodgings, -> { as_parent.published.order('created_at desc').limit(4) }

  translates :title, :subtitle, :description, :meta_desc, :meta_title, :slug, :h1, :h2, :h3, :highlight_1, :highlight_2, :highlight_3, :summary, :short_desc, :location_description

  enum lodging_type: {
    villa: 1,
    apartment: 2,
    bnb: 3,
    small_resort: 4,
    boutique_hotels: 5,
  }

  enum presentation: {
    as_parent: 1,
    as_standalone: 2,
    as_child: 3,
  }

  enum channel: {
    standard: 0,
    guest_centric: 1,
    room_raccoon: 2,
    open_gds: 3,
  }

  after_create :add_availabilities, if: :published?
  after_create :reindex_prices, :reindex_experiences_and_region

  def self.ransackable_scopes(*)
    %i(country_id_eq)
  end

  def not_available_on
    (Date.today..2.years.from_now).map(&:to_s) - availabilities.pluck(:available_on).map(&:to_s)
  end

  def discount_dates
    all_discounts.active.collect { |discount| (discount.start_date..discount.end_date).map(&:to_s) }.flatten
  end

  def option_dates
    reservations.confirmed_options.collect { |resv| (resv.check_in..resv.check_out).map(&:to_s) }.flatten
  end

  def customized_dates
    [{ "cssClass": "discount" , "dates": discount_dates }, { "cssClass": "option" , "dates": option_dates } ].to_json
  end

  def children_not_available_on
    return not_available_on unless lodging_children.present?
    _availabilities = []
    lodging_children.includes(:availabilities).each do |lodging_child|
      _availabilities += lodging_child.availabilities.pluck(:available_on).map(&:to_s)
    end
    (Date.today..2.years.from_now).map(&:to_s) - _availabilities
  end

  def gc_not_available_on params = {}
    result = GetGuestCentricRates.call self, params
    result['response'].collect { |r| r['day'] if r['value'].to_f <= 0 }.compact rescue []
  end

  def be_not_available_on
    availabilities = GetBookingExpertAvailabilities.call(self).pluck(:start_date)
    disable_dates, date = [], Date.today
    availabilities.length.times do
      disable_dates << date.to_s unless availabilities.include? date.to_s
      date = date.next
    end
    disable_dates
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
        rules: { type: :nested },
        availability_price: { type: :long },
      }
    }
  }

  def search_data
    attributes.merge(
      location: { lat: latitude, lon: longitude },
      country_id: country.id,
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
      discounts: discounts.active.present?,
      total_reviews: all_reviews.count,
    )
  end

  def should_index?
    published?
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
    discount({ check_in: values[0], check_out: values[1], lodging_id: id })
  end

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?)
      self.calculated_price = price.to_f.round(2)
      return self.dynamic_price = false
    end
    total_price = price_list(params.merge(flexible: false))[:rates].sum
    total_discount = calculate_discount(discount(params), total_price)
    total_price -= total_discount if total_discount.present?
    self.calculated_price = total_price.round(2)
    self.dynamic_price = true
  end

  def allow_check_in_days
    days = rules_active(Date.today, Date.today).pluck(:check_in_days).join(',')
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
    return name unless as_child? && name.include?('-')
    name.split('-').last.strip
  end

  def flexible_search
    @flexible_search || false
  end

  def extended_name
    "#{name} - #{lodging_type} - #{country.name} #{region.name}"
  end

  def all_discounts
    return discounts.active if as_standalone? || as_child?
    Discount.active.where(lodging_id: lodging_children.ids)
  end

  def all_reviews
    return reviews_published.desc if as_standalone?
    _parent = parent.presence || self
    Review.published.where(lodging_id: _parent.lodging_children.ids.push(_parent.id)).includes(:translations).desc
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
    availabilities_list = []
    dates.each do |date|
      availabilities_list << Availability.new(available_on: date, lodging_id: id, created_at: DateTime.now, updated_at: DateTime.now)
    end
    Availability.import availabilities_list, on_duplicate_key_update: { conflict_target: [:lodging_id, :available_on], columns: [:updated_at] }, batch_size: 150
  end

  def display_price_notice?
    !(confirmed_price && confirmed_price_2020)
  end

  def feature
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: [longitude, latitude]
      },
      properties: {
        icon: {
          className: "map-price-icon price-icon-#{id}",
          html: "€<span class='marker-price'>#{price}</span>",
          iconSize: nil
        },
        id: id,
        title: name,
        description: feature_description,
        url: Rails.application.routes.url_helpers.lodging_path(self),
        image: images.try(:first),
        'marker-color': marker_color,
        'marker-size': 'large',
        'marker-symbol': lodging_type[0],
      }
    }
  end

  def feature_description
    description = "#{minimum_adults} - #{adults} #{I18n.t('search.adutls_1')} <br>"
    description += "#{minimum_children} - #{children} #{I18n.t('search.children_1')} <br>" if children.present?
    description += "#{beds} #{I18n.t('search.bedrooms')} - #{baths} #{I18n.t('search.bathrooms')} <br>"
  end

  def marker_color
    return '#1F618D' if villa?
    return '#7D3C98' if apartment?
    '#dc9813'
  end

  def price_list(params)
    return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless params[:check_in].present? && params[:check_out].present?
    total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i
    SearchPriceWithFlexibleDates.call(params.merge(lodging_id: id, minimum_stay: total_nights, max_adults: adults.to_i), self)
  end

  def discount(params)
    return unless params[:check_in].present? && params[:check_out].present?
    SearchDiscounts.call(params.merge(lodging_id: self.id))
  end

  def cleaning_cost_for guests, nights
    total_cost = 0
    cleaning_costs.for_guests(guests).each do |cleaning_cost|
      if cleaning_cost.fixed_price > 0
        total_cost += cleaning_cost.fixed_price
      elsif cleaning_cost.price_per_day > 0
        total_cost += (cleaning_cost.price_per_day * nights.to_f)
      end
    end
    total_cost
  end

  def first_available_date disable_dates
    date = Date.today

    300.times do
      return date unless disable_dates.include? date.to_s
      date = date.next
    end
    date
  end

  def find_gc_room gc_id
    lodging_children.where("gc_rooms @> ?", "{#{gc_id}}").take
  end

  def lowest_child_price
    lodging_children.published.pluck(:price).min
  end

  def belongs_to_channel?
    %w[room_raccoon open_gds].include?(channel)
  end

  private
    def add_availabilities
      add_availabilities_for (Date.today..365.days.from_now).map(&:to_s)
    end

    def calculate_discount(discounts, total_price)
      return unless discounts.present?
      amount = 0
      discounts.each do |dis|
        amount += (total_price * (dis[:value].to_i/100)) if dis[:discount_type] == 'percentage'
        amount += dis[:value].to_i if dis[:discount_type] == 'amount' || dis[:discount_type] == 'incentive'
      end
      amount
    end

    def reindex_prices
      prices.reindex
    end

    def reindex_experiences_and_region
      experiences.reindex && region.reindex
    end
end
