class Lodging < ApplicationRecord
  belongs_to :owner, optional: true
  belongs_to :region
  has_many :reservations
  has_many :users, through: :reservations
  has_many :availabilities
  has_many :prices, through: :availabilities
  has_many :room_rates, foreign_key: :child_lodging_id
  has_many :room_rate_availabilities, through: :room_rates, source: :availabilities
  has_many :room_rate_prices, through: :room_rate_availabilities, source: :prices
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
  has_many :lodging_children, class_name: 'Lodging', foreign_key: :parent_id
  has_many :rate_plans, class_name: 'RatePlan', foreign_key: :parent_lodging_id
  has_many :parent_rate_plans, through: :parent, source: :rate_plans
  has_many :room_rate_plans, through: :room_rates, source: :rate_plan
  has_many :children_room_rates, through: :lodging_children, source: :room_rates
  has_many :children_room_rates_availabilities, through: :children_room_rates, source: :availabilities
  has_many :children_room_rates_prices, through: :children_room_rates_availabilities, source: :prices
  has_many :children_availabilities, through: :lodging_children, source: :availabilities
  has_many :children_rules, through: :lodging_children, source: :rules

  include ImageHelper

  attr_accessor :flexible_search
  attr_accessor :calculated_price
  attr_accessor :dynamic_price
  attr_accessor :price_valid, :price_errors
  attr_accessor :first_available_room, :check_in, :check_out

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
  delegate :full_name, :image_url, :pre_payment, :final_payment, to: :owner, allow_nil: true, prefix: true
  delegate :country, to: :region, allow_nil: true
  delegate :name, to: :region, allow_nil: true, prefix: true
  delegate :name, to: :country, allow_nil: true, prefix: true
  delegate :with_in, :for_range, to: :availabilities, allow_nil: true, prefix: true
  delegate :desc, :published, to: :reviews, allow_nil: true, prefix: true
  delegate :including_text, :particularities_text, :pay_text, :options_text, :payment_terms_text, :deposit_text, to: :price_text, allow_nil: true
  delegate :admin_user, to: :owner, allow_nil: true
  delegate :summary, :location_description, :h1, to: :parent, allow_nil: true, prefix: true
  delegate :not_available, to: :room_rate_availabilities, prefix: true, allow_nil: true

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
    return (Date.today..2.years.from_now).map(&:to_s) - availabilities.pluck(:available_on).map(&:to_s) unless belongs_to_channel?

    room_rate_availabilities_not_available.pluck(:available_on).uniq.map(&:to_s)
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
    return children_room_rates_availabilities.not_available.pluck(:available_on) if belongs_to_channel?

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

  searchkick batch_size: 200, routing: true, locations: [:location], text_middle: [:name], merge_mappings: true, mappings: {
    lodging: {
      properties: {
        rules: { type: :nested },
        availability_price: { type: :long },
        availabilities: { type: :nested },
        room_rates: {
          type: :nested,
          properties: {
            availabilities: { type: :nested }
          }
        },
        relation_type: {
          type: :join,
          eager_global_ordinals: true,
          relations: {
            parent: :child
          }
        }
      }
    }
  }

  def search_data
    _children = lodging_children.published if as_parent?
    _availabilities = availabilities.active
    attributes.merge(
      location:              { lat: latitude, lon: longitude },
      country_id:            country.id,
      country:               country.translated_slugs,
      region:                region.translated_slugs,
      extended_name:         extended_name,
      available_on:          ((as_parent? || belongs_to_channel?) && []) || _availabilities.pluck(:available_on),
      availability_price:    availability_price,
      adults_and_children:   adults_plus_children,
      amenities:             amenities.collect(&:name),
      amenities_ids:         amenities.ids,
      experiences:           experiences.collect(&:translated_slugs),
      experiences_ids:       experiences.ids,
      discounts:             discounts.active.present?,
      rules:                 ((as_parent? || belongs_to_channel?) && []) || rules.collect(&:search_data),
      total_reviews:         all_reviews.count,
      availabilities:        ((as_parent? || belongs_to_channel?) && []) || _availabilities.collect(&:search_data),
      checkout_dates:        checkout_dates,
      room_rates:            room_rates.published.with_active_rate_plan.collect(&:search_data)
    ).merge(relation_type)
  end

  def search_routing
    (parent_id || id).to_i.to_s
  end

  def should_index?
    published?
  end

  def self.flush_cached_searched_data
    Rails.cache.delete_matched('V2::SearchLodgings*')
    Rails.cache.delete_matched('Lodging/calculate_prices*')
    CacheLodgingsJob.perform_later
  end

  def relation_type
    return { relation_type: { name: 'parent' } } if as_parent? || as_standalone?
    { relation_type: { name: 'child', parent: parent_id.to_s } }
  end

  def availability_price
    return prices.pluck(:amount).presence || [price] unless belongs_to_channel?
    return children_room_rates_prices.pluck(:amount).presence || children_room_rates.pluck(:default_rate) if as_parent?
    room_rate_prices.pluck(:amount).presence || room_rates.pluck(:default_rate)
  end

  def adults_plus_children
    return adults.to_i + children.to_i unless as_parent?
    child_lodgings = lodging_children
    child_lodgings.pluck(:adults).select(&:present?).max.to_i + child_lodgings.pluck(:children).select(&:present?).max.to_i
  end

  def price_details(values:, flexible: true, daily_rate: false, calendar_departure: false)
    price_list({ check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], flexible: flexible, daily_rate: daily_rate, calendar_departure: calendar_departure })
  end

  def discount_details(values)
    discount({ check_in: values[0], check_out: values[1], lodging_id: id })
  end

  def cumulative_price(params)
    params[:children] = params[:children].presence || 0
    unless params.values_at(:check_in, :check_out, :adults, :children).all?(&:present?) || params.values_at(:months, :adults, :children).all?(&:present?)
      self.calculated_price = price.to_f.round(2)
      return self.dynamic_price = false
    end

    prices = price_list(params)
    total_price = prices[:rates].sum
    total_discount = calculate_discount(discount(params), total_price)
    total_price -= total_discount if total_discount.present?
    self.calculated_price = total_price.round(2)
    self.dynamic_price = true
    self.price_valid = prices[:valid]
    self.price_errors = prices[:errors]
    self.check_in = prices[:check_in]
    self.check_out = prices[:check_out]
  end

  def self.calculate_prices(params, lodging_ids, search_analytic)
    cache_key = ['Lodging', __method__, search_analytic.params['lodgings']]
    Rails.cache.fetch(cache_key, expires_in: 24.hours) do
      lodgings = Lodging.where(id: lodging_ids).includes({ room_rates: [{ rate_plan: :rule }, :parent_lodging, :child_lodging] }, :translations)
      lodgings.each do |lodging|
        if lodging.belongs_to_channel?
          lodging.room_rates.select{ |room_rate| room_rate.publish && !room_rate.rate_plan_expired? }.each do |room_rate|
            room_rate.cumulative_price(params.clone)
            lodging.check_in = room_rate.check_in
            lodging.check_out = room_rate.check_out
            lodging.calculated_price = room_rate.calculated_price
            lodging.dynamic_price = room_rate.dynamic_price
            lodging.price_valid = room_rate.price_valid
            lodging.price_errors = room_rate.price_errors
            break if room_rate.price_valid && params[:accom_listing]
          end
        else
          lodging.cumulative_price(params.clone)
        end
      end

      lodgings
    end
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
    return { rates: {}, search_params: params, valid: false, errors: { base: ['check_in & check_out dates must exist'] } } unless (params[:check_in].present? && params[:check_out].present?) || params[:months].present?
    total_nights = (params[:check_out].to_date - params[:check_in].to_date).to_i if params[:check_in].present? && params[:check_out].present?
    SearchPriceWithFlexibleDates.call(params.merge(lodging_id: id, minimum_stay: (total_nights || params[:minimum_stay]).to_i, max_adults: adults.to_i), self)
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
    return children_room_rates.select(&:publish).pluck(:default_rate).reject(&:blank?).min.to_f if belongs_to_channel?

    lodging_children.select(&:published).pluck(:price).reject(&:blank?).min.to_f
  end

  def belongs_to_channel?
    %w[room_raccoon open_gds].include?(channel)
  end

  def availabilities_wrt_channel
    return room_rate_availabilities.with_published_room_rates if belongs_to_channel?
    availabilities
  end

  def channel_managers_availabilities
    room_rate_availabilities.active.with_published_room_rates.where("booking_limit > ?", 0)
  end

  def first_available_child_wrt lodgings
    lodging_hit = lodgings.hits.find { |hit| hit['_id'].to_i == id }
    return unless lodging_hit.present?

    lodging_hit = lodging_hit['inner_hits'].collect {|inner_hit| inner_hit }.flatten.collect { |inner_hit| inner_hit.slice('hits') }.delete_if(&:blank?).first
    return unless lodging_hit.present?

    lodging_hit['hits']['hits'].first['_id'] rescue nil
  end

  def available_children_wrt lodgings
    lodging_hit = lodgings.hits.find { |hit| hit['_id'].to_i == id }
    return unless lodging_hit.present?

    lodging_hit = lodging_hit['inner_hits'].collect {|inner_hit| inner_hit }.flatten.collect { |inner_hit| inner_hit.slice('hits') }.delete_if(&:blank?).first
    return unless lodging_hit.present?

    lodging_hit['hits']['hits'].count rescue 0
  end

  private
    def add_availabilities
      return if belongs_to_channel?
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

    def checkout_dates
      return [] unless belongs_to_channel?
      channel_managers_availabilities.select { |availability|  !availability.check_out_closed? }.collect(&:available_on)
    end

    def rules_wrt_presentation
      _rules = (as_parent? && rules) || children_rules
      _rules.with_published_lodgings
    end
end
