class Reservation < ApplicationRecord
  belongs_to :booking
  belongs_to :lodging
  belongs_to :room_rate, optional: true
  has_one :child_lodging, through: :room_rate
  has_one :rate_plan, through: :room_rate
  has_many :rules, through: :lodging
  has_many :cleaning_costs, through: :lodging
  has_one :review
  has_one :user, through: :booking
  has_many :child_rates, through: :rate_plan

  validates :check_in, :check_out, presence: true
  validate :availability
  validate :no_of_guests
  validate :accommodation_rules, unless: :belongs_to_channel?
  validate :accommodation_rate_plan_rule, if: :belongs_to_channel?

  after_validation :update_lodging_availability, unless: :belongs_to_channel?
  # after_validation :update_room_rate_availability, if: :belongs_to_channel?, on: :update
  # after_commit :send_reservation_details
  after_create :update_price_details
  after_destroy :send_reservation_removal_details

  delegate :active, :active_flexible, to: :rules, prefix: true, allow_nil: true
  delegate :slug, :name, :child_name, :confirmed_price, :image, :address, :average_rating, :parent, :belongs_to_channel?, to: :lodging, prefix: true, allow_nil: true
  delegate :user, :identifier, :created_by, to: :booking, allow_nil: true
  delegate :email, :first_name, :last_name, :full_name, :phone, to: :user, prefix: true
  delegate :id, :confirmed, to: :booking, prefix: true
  # delegate :code, :description, to: :room_type, prefix: true
  delegate :code, :rule, to: :rate_plan, prefix: true, allow_nil: true
  delegate :open_gds_rate_id, to: :rate_plan, allow_nil: true
  delegate :open_gds_accommodation_id, :open_gds?, to: :child_lodging, allow_nil: true
  delegate :infants, :children, to: :child_rates, prefix: true, allow_nil: true

  scope :not_canceled, -> { where(canceled: false) }
  scope :in_cart, -> { where(in_cart: true) }
  scope :requests, -> { where(in_cart: false, canceled: false) }
  scope :non_confirmed, -> { requests.joins(:booking).where(bookings: { confirmed: false }) }
  scope :confirmed_options, -> { requests.option.confirmed }
  scope :future_booking_ids, -> (booking_ids) { where(booking_id: booking_ids).where('check_out >= ? and canceled = ?', Date.today, false).pluck(:booking_id).uniq }

  scope :guest_centric, -> { where.not(offer_id: nil) }
  scope :booking_expert, -> { where.not(be_category_id: nil) }
  scope :room_raccoon, -> { joins(:lodging).where(lodgings: { channel: 2 }) }
  scope :open_gds, -> { joins(:child_lodging).where(lodgings: { channel: 3 }) }
  scope :open_gds_without_online_payment, -> { open_gds.where(open_gds_online_payment: false) }

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
    return self.rent = lodging.price_details([check_in.to_s, check_out.to_s, adults, children, infants], false)[:rates].sum unless belongs_to_channel?

    self.rent = room_rate.price_details([check_in.to_s, check_out.to_s, adults, children, infants])[:rates].sum
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

  def booking_expert?
    be_category_id.present?
  end

  def step_passed?(step)
    Reservation.booking_statuses[booking_status] >= Reservation.booking_statuses[step]
  end

  def total_rent
    rent.to_f + cleaning_cost.to_f - discount.to_f
  end

  def booking_expert_total
    rent.to_f + tax_and_additional_fee.to_f
  end

  def self.arrival_status
    _arrivals = {}
    joins(lodging: { region: :country }).select("in_cart, check_in, countries.id").where("in_cart = ? and check_in >= ? and request_status = ?", false, Date.today, 1).group(:"countries.id").group_by_month(:check_in).count("id").map { |arrival| _arrivals[arrival.first[0]].present? ? _arrivals[arrival.first[0]] << [arrival.first[1], arrival.last] : _arrivals[arrival.first[0]] = [[arrival.first[1], arrival.last]] }
    _arrivals
  end

  def is_managed_by_n2s?
    cleaning_costs.try(:first).try(:manage_by)
  end

  def belongs_to_channel?
    lodging_belongs_to_channel?
  end

  private
    def update_lodging_availability
      return if in_cart? || prebooking? || option? || offer_id.present?
      lodging.availabilities.check_out_only!(check_in)
      lodging.availabilities.where(available_on: (check_in+1.day..check_out-1.day).map(&:to_s)).destroy_all
      lodging.availabilities.where(available_on: check_out, check_out_only: true).delete_all
    end

    # def update_room_rate_availability
    #   return if in_cart? || prebooking? || option?
    #
    #   _availabilities = room_rate.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s))
    #   _availabilities.each do |availability|
    #     availability.rr_booking_limit -= rooms
    #   end
    #
    #   Availability.import _availabilities.to_ary, batch_size: 150, on_duplicate_key_update: { columns: [:rr_booking_limit] } if _availabilities.present?
    # end

    def availability
      return unless check_in.present? && check_out.present? && lodging.present? && offer_id.blank?

      errors.add(:check_in, "& check out dates must be different") if (check_out - check_in).to_i < 1
      if belongs_to_channel?
        validate_room_rate_availabilities
      else
        _availabilities = lodging.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s))
        check_out_days = _availabilities.where(check_out_only: true)
        errors.add(:base, "Not available for selected dates") if _availabilities.where(check_out_only: false).count < (check_out - check_in).to_i || check_in < Date.today || check_out_days.present?
      end
    end

    def accommodation_rules
      return unless check_in.present? && check_out.present? && lodging.present? && offer_id.blank?

      nights = (check_out - check_in).to_i
      active_rules = rules_active(check_in, check_out).presence || rules_active_flexible(check_in, check_out)
      errors.add(:base, "The maximum allowed stay is 21 nights") if nights > 21

      if active_rules.present?
        count = 0
        active_rules.each do |rule|
          if (rule.checkin_day.present? && rule.checkin_day != check_in.strftime("%A").downcase && !rule.any?) || (rule.minimum_stay.present? && rule.minimum_stay.exclude?(nights))
            count += 1
          end
        end
        if count == active_rules.length
          errors.add(:check_in, rules_validation_message(check_in, check_out))
        end
      else
        errors.add(:check_in, "day should be #{lodging.check_in_day}") unless check_in.strftime("%A") == lodging.check_in_day.try(:titleize) || lodging.flexible_arrival
        errors.add(:base, "The stay should be in multiple of 7 nights") unless nights % 7 == 0 || lodging.flexible_arrival
      end
    end

    def no_of_guests
      return if lodging.present? && lodging.room_raccoon?

      if lodging.open_gds?
        max_occupants = child_lodging.adults + child_lodging.extra_beds
        occupants = adults.to_i + children.to_i + infants.to_i
        return errors.add(:base, "Maximum #{max_occupants} occupants are allowed") if max_occupants < occupants
        return unless child_lodging.extra_beds_for_children_only && extra_bed_used?

        errors.add(:base, 'Extra Beds are only available for children / infants') if child_lodging.adults < adults.to_i
      else
        return unless lodging.adults.present? && offer_id.blank?
        return errors.add(:base, "Maximum #{lodging.adults} adults are allowed") if lodging.adults < adults.to_i

        children_vacancies = lodging.children.to_i + lodging.adults - adults.to_i
        errors.add(:base, "Maximum #{children_vacancies} children are allowed") if children_vacancies < children.to_i
      end
    end

    def update_price_details
      return if skip_data_posting || offer_id.present? || be_category_id.present?

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

    def validate_room_rate_availabilities
      _availabilities = room_rate.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s)).order(:available_on)
      nights = (check_out - check_in).to_i
      if _availabilities.present?
        min_booking_limit = _availabilities.pluck(:rr_booking_limit).min
        errors.add(:rooms, "Minimum rooms available from #{check_in} to #{check_out} are #{min_booking_limit}") if rooms > min_booking_limit
        errors.add(:check_in, "Check-in not possible on #{check_in}")  if _availabilities.first.rr_check_in_closed && _availabilities.first.available_on == check_in
        errors.add(:check_out, "Check-out not possible on #{check_out}")  if _availabilities.last.rr_check_out_closed && _availabilities.last.available_on == check_out
        count = 0
        _availabilities.each do |availability|
          count += 1 if (availability.rr_minimum_stay.present? && availability.rr_minimum_stay.exclude?(nights.to_s))
        end

        if count == _availabilities.length
          message = "days should be "
          _availabilities.each_with_index do |availability, index|
            available_day = availability.available_on.strftime("%A")
            message += "#{ ', ' if index > 0 } #{ available_day.try(:upcase) } (#{ availability.rr_minimum_stay.to_sentence(last_word_connector: ' or ', two_words_connector: ' or ') } nights)"
          end
          errors.add(:base, message)
        end
      end

      errors.add(:base, "Not available for selected dates") if check_in < Date.today && _availabilities.blank?
    end

    def accommodation_rate_plan_rule
      return unless check_in.present? && check_out.present? && lodging.present? && lodging.open_gds?

      rule = rate_plan_rule
      errors.add(:check_in, "Check-in not possible on #{check_in}") if check_in < rule.start_date || check_in > rule.end_date
      errors.add(:check_out, "Check-out not possible on #{check_out}") if check_out < rule.start_date || check_out > rule.end_date
      errors.add(:check_in, "Check-in Possible only on #{rule.open_gds_arrival_days}") if rule.open_gds_arrival_days.exclude?(check_in.strftime('%A').downcase)
      return if rule.restriction_type_disabled?

      required_check_in = Date.current + rule.open_gds_restriction_days
      return errors.add(:check_in, "Check-in possible from #{rule.open_gds_restriction_days.days.from_now.to_date}") if rule.restriction_type_till? && check_in < required_check_in

      errors.add(:check_in, "Check-in possible till #{rule.open_gds_restriction_days.days.from_now}") if rule.restriction_type_from? && check_in > required_check_in
    end

    def extra_bed_used?
      (child_lodging.adults - (adults + children + infants)).negative?
    end
end
