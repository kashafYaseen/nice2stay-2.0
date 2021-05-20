class Booking < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reservations
  has_many :room_types, through: :reservations

  scope :in_cart, -> { where(in_cart: true) }
  scope :requests, -> { where(in_cart: false, canceled: false) }
  scope :confirmed, -> { requests.where(confirmed: true) }
  scope :upcoming, -> { where(id: Reservation.future_booking_ids(ids)) }
  scope :old, -> { where.not(id: Reservation.future_booking_ids(ids)) }
  scope :by_nice2stay, -> { where.not("be_identifier LIKE 'BYHOUSEOWNER%'") }
  scope :by_partner, -> { where("be_identifier LIKE 'BYHOUSEOWNER%'") }
  scope :not_by_partners, -> { where(created_by: [0, 2]) }

  accepts_nested_attributes_for :reservations
  accepts_nested_attributes_for :user

  # after_update :send_details

  delegate :full_name, :first_name, :last_name, :email, :phone, :city, :zipcode, :country_name, to: :user, prefix: true, allow_nil: true
  delegate :open_gds, :open_gds_without_online_payment, :open_gds_with_online_payment, :canceled, to: :reservations, prefix: true, allow_nil: true

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

  enum created_by: {
    customer: 0,
    houseowner: 1,
    nice2stay: 2,
    hotelandbeyond: 3,
  }

  attr_accessor :skip_data_posting

  def identifier
    be_identifier || "#{user_identifier}#{created_at.to_i}"
  end

  def user_identifier
    (user.try(:last_name) || 'By Houseowner').split(' ').join('').upcase
  end

  def total_payment
    pre_payment + final_payment
  end

  def pre_payment_amount
    reservations.includes(:child_lodging).inject(0) do |sum, reservation|
      if reservation.open_gds?
        reservation.open_gds_online_payment && reservation.open_gds_deposit_amount.positive? ? sum + reservation.open_gds_deposit_amount : (sum + reservation.total_price) * 0.3
      else
        0.3 * (reservation.booking_expert? || reservation.room_rate_id.present? ? sum + reservation.total_price : sum + reservation.rent)
      end
    end
  end

  def final_payment_amount
    reservations.includes(:child_lodging).inject(0) do |sum, reservation|
      if reservation.open_gds?
        reservation.open_gds_online_payment && reservation.open_gds_deposit_amount.positive? ? sum + (reservation.total_price - reservation.open_gds_deposit_amount) : sum + reservation.total_price * 0.7
      else
        0.7 * (reservation.booking_expert? || reservation.room_rate_id.present? ? sum + reservation.total_price : sum + reservation.rent)
      end
    end
  end

  def step_passed?(step)
    return false unless booking_status?
    return false if option?
    Booking.booking_statuses[booking_status] >= Booking.booking_statuses[step]
  end

  def pre_paid_at!(datetime)
    reservations.update_all(booking_status: 'pre_paid')
    update(pre_payed_at: datetime, booking_status: 'pre_paid')
  end

  def final_paid_at!(datetime)
    reservations.update_all(booking_status: 'fully_paid')
    update(final_payed_at: datetime, booking_status: 'fully_paid')
  end

  private
    def send_details
      return if in_cart || skip_data_posting
      SendBookingDetailsJob.perform_later(self.id)
    end
end
