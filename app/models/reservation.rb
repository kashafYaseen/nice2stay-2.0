class Reservation < ApplicationRecord
  belongs_to :booking
  belongs_to :lodging
  has_many :rules, through: :lodging
  has_many :cleaning_costs, through: :lodging
  has_one :review

  validates :check_in, :check_out, presence: true
  validate :availability
  validate :no_of_guests
  validate :accommodation_rules

  after_validation :update_lodging_availability
  #after_commit :send_reservation_details
  after_create :update_price_details
  after_destroy :send_reservation_removal_details

  delegate :active, :active_flexible, to: :rules, prefix: true, allow_nil: true
  delegate :slug, :name, :child_name, :confirmed_price, :image, :address, :average_rating, :parent, to: :lodging, prefix: true, allow_nil: true
  delegate :user, :identifier, :created_by, to: :booking, allow_nil: true
  delegate :email, :full_name, to: :user, prefix: true
  delegate :id, :confirmed, to: :booking, prefix: true

  scope :not_canceled, -> { where(canceled: false) }
  scope :in_cart, -> { where(in_cart: true) }
  scope :requests, -> { where(in_cart: false, canceled: false) }
  scope :non_confirmed, -> { requests.joins(:booking).where(bookings: { confirmed: false }) }
  scope :confirmed_options, -> { requests.option.confirmed }
  scope :future_booking_ids, -> (booking_ids) { where(booking_id: booking_ids).where('check_out >= ? and canceled = ?', Date.today, false).pluck(:booking_id).uniq }

  scope :guest_centric, -> { where.not(offer_id: nil) }

  accepts_nested_attributes_for :review

  attr_accessor :skip_data_posting

  enum booking_status: {
    prebooking: 0,
    booked: 1,
    customer_data_requested: 2,
    confirmation_sent: 3,
    pre_paid: 4,
    fully_paid: 5,
    route_sent: 6,
    arrival_email_sent: 7,
    option: 8,
    request_price: 9,
  }

  enum request_status: {
    pending: 0,
    confirmed: 1,
    rejected: 2,
    canceled: 3,
  }

  def can_review? user
    user == self.user && review.blank?
  end

  def total_nights
    return unless check_out.present? && check_in.present?
    (check_out - check_in).to_i
  end

  def calculate_rent
    self.rent = lodging.price_details([check_in.to_s, check_out.to_s, adults, children, infants], false)[:rates].sum
  end

  def total_meal_price
    (meal_price.to_f * total_nights.to_i * rooms.to_i).round(2)
  end

  def total_meal_tax
    (meal_tax.to_f * total_nights.to_i * rooms.to_i).round(2)
  end

  def tax_and_additional_fee
    (total_meal_tax.to_f + tax.to_f + additional_fee.to_f).round(2)
  end

  def guest_centric?
    offer_id.present?
  end

  def step_passed?(step)
    Reservation.booking_statuses[booking_status] >= Reservation.booking_statuses[step]
  end

  def total_rent
    rent.to_f + cleaning_cost.to_f - discount.to_f
  end

  def self.arrival_status
    _arrivals = {}
    joins(lodging: { region: :country }).select("in_cart, check_in, countries.id").where("in_cart = ? and check_in >= ? and request_status = ?", false, Date.today, 1).group(:"countries.id").group_by_month(:check_in).count("id").map { |arrival| _arrivals[arrival.first[0]].present? ? _arrivals[arrival.first[0]] << [arrival.first[1], arrival.last] : _arrivals[arrival.first[0]] = [[arrival.first[1], arrival.last]] }
    _arrivals
  end

  def is_managed_by_n2s?
    cleaning_costs.try(:first).try(:manage_by)
  end

  private
    def update_lodging_availability
      return if in_cart? || prebooking? || option? || offer_id.present?
      lodging.availabilities.check_out_only!(check_in)
      lodging.availabilities.where(available_on: (check_in+1.day..check_out-1.day).map(&:to_s)).destroy_all
      lodging.availabilities.where(available_on: check_out, check_out_only: true).delete_all
    end

    def availability
      return unless check_in.present? && check_out.present? && lodging.present? && offer_id.blank?
      errors.add(:check_in, "& check out dates must be different") if (check_out - check_in).to_i < 1
      _availabilities = lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s))
      check_out_days = _availabilities.where(check_out_only: true)
      errors.add(:base, "Not available for selected dates") if _availabilities.where(check_out_only: false).count < (check_out - check_in).to_i || check_in < Date.today || check_out_days.present?
    end

    def accommodation_rules
      return unless check_in.present? && check_out.present? && lodging.present? && offer_id.blank?
      nights = (check_out - check_in).to_i
      applied_rules = rules_active(check_in, check_out).presence || rules_active_flexible(check_in, check_out)
      errors.add(:base, "The maximum allowed stay is 21 nights") if nights > 21

      if applied_rules.present?
        count = 0
        applied_rules.each do |rule|
          if (rule.checkin_day.present? && rule.checkin_day != check_in.strftime("%A").downcase && !rule.any?) || (rule.minimum_stay.present? && rule.minimum_stay.exclude?(nights))
            count += 1
          end
        end
        if count == applied_rules.length
          errors.add(:check_in, rules_validation_message(check_in, check_out))
        end
      else
        errors.add(:check_in, "day should be #{lodging.check_in_day}") unless check_in.strftime("%A") == lodging.check_in_day.try(:titleize) || lodging.flexible_arrival
        errors.add(:base, "The stay should be in multiple of 7 nights") unless nights % 7 == 0 || lodging.flexible_arrival
      end
    end

    def no_of_guests
      return unless lodging.present? && lodging.adults.present? && offer_id.blank?
      return errors.add(:base, "Maximum #{lodging.adults} adults are allowed") if lodging.adults < adults.to_i

      children_vacancies = lodging.children.to_i + lodging.adults - adults.to_i
      errors.add(:base, "Maximum #{children_vacancies} children are allowed") if children_vacancies < children.to_i
    end

    def update_price_details
      return if skip_data_posting || offer_id.present?
      rent = calculate_rent
      update_columns rent: rent, total_price: (rent - discount.to_f)
    end

    def rules_validation_message check_in, check_out
      message = " days should be"
      rules.active(check_in, check_out).each_with_index do |rule, index|
        day = rule.any? ? 'any day' : rule.checkin_day
        message += "#{',' if index > 0} #{day.try(:upcase)} (#{rule.minimum_stay.to_sentence(last_word_connector: ' or ', two_words_connector: ' or ')} nights)"
      end
      message
    end

    # def send_reservation_details
    #   SendBookingDetailsJob.perform_later(self.booking_id) unless skip_data_posting || in_cart
    # end

    def send_reservation_removal_details
      SendReservationRemovalDetailsJob.perform_later(self.id, self.crm_booking_id, self.booking_id) unless skip_data_posting || booking.in_cart
    end
end
