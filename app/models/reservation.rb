class Reservation < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lodging_child
  has_one :lodging, through: :lodging_child
  has_many :rules, through: :lodging
  has_one :review

  validates :check_in, :check_out, presence: true
  validate :availability
  validate :no_of_guests
  validate :check_out_only
  validate :accommodation_rules

  after_commit :update_lodging_availability
  after_commit :send_reservation_details
  after_create :update_price_details

  delegate :active, to: :rules, prefix: true, allow_nil: true
  delegate :slug, :name, :image, to: :lodging, prefix: true, allow_nil: true
  delegate :email, to: :user, prefix: true
  delegate :id, to: :lodging_child, prefix: true

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
    option: 8 ,
    request_price: 9,
    canceled: 10,
    in_cart: 11,
  }

  def can_review? user
    user == self.user && review.blank?
  end

  def total_nights
    return unless check_out.present? && check_in.present?
    (check_out - check_in).to_i
  end

  def calculate_rent
    rent = lodging.price_details([check_in.to_s, check_out.to_s, adults, children, infants, lodging_child_id]).sum
  end

  def calculate_discount
    discount = ((lodging.discount_details([check_in, check_out]) || 0) / 100) * rent
  end

  private
    def update_lodging_availability
      return if in_cart?
      lodging_child.availabilities.check_out_only!(check_in)
      lodging_child.availabilities.where(available_on: (check_in+1.day..check_out-1.day).map(&:to_s)).destroy_all
      lodging_child.availabilities.where(available_on: check_out, check_out_only: true).delete_all
    end

    def availability
      return unless check_in.present? && check_out.present? && lodging_child.present?
      errors.add(:check_in, "& check out dates must be different") if (check_out - check_in).to_i < 1
      available_days = lodging_child.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s), check_out_only: false).count
      errors.add(:base, "lodging is not available for selected dates") if available_days < (check_out - check_in).to_i || check_in < Date.today
    end

    def check_out_only
      return unless check_in.present? && check_out.present? && lodging.present?
      check_out_days = lodging_child.availabilities.where(available_on: (check_in..check_out-1.day).map(&:to_s), check_out_only: true)
      errors.add(:base, "#{check_out_days.pluck(:available_on)} only available for check out") if check_out_days.present?
    end

    def accommodation_rules
      return unless lodging.present?
      nights = (check_out - check_in).to_i

      rules_active(check_in, check_out).each do |rule|
        if rule.days_multiplier.present?
          errors.add(:base, "Minimaal is #{rule.days_multiplier} nachten verblijf in deze periode") unless nights % rule.days_multiplier == 0
          errors.add(:base, "Check in day should be #{rule.check_in_days}") unless check_in.strftime("%A") == rule.check_in_days.titleize
        elsif rule.minimal_stay.present? && nights != 7 && nights < rule.minimal_stay.collect(&:to_i).max
          errors.add(:base, "Minimaal is #{rule.minimal_stay.collect(&:to_i).min} nachten verblijf in deze periode") unless nights.to_s.in?(rule.minimal_stay)
        end
      end
    end

    def no_of_guests
      return unless lodging.adults.present?
      if lodging.adults < adults.to_i
        errors.add(:base, "Maximum #{lodging.adults} adults are allowed")
        return
      end
      children_vacancies = lodging.children.to_i + lodging.adults.to_i - adults.to_i
      errors.add(:base, "Maximum #{children_vacancies} children are allowed") if children_vacancies < children.to_i
    end

    def update_price_details
      rent, discount = calculate_rent, calculate_discount
      update_columns rent: rent, discount: discount, total_price: (rent - discount)
    end

    def send_reservation_details
      SendReservationDetailsJob.perform_later(self.id) unless skip_data_posting || in_cart?
    end
end
