class Booking < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reservations

  scope :in_cart, -> { where(in_cart: true) }
  scope :requests, -> { where(in_cart: false) }
  scope :confirmed, -> { requests.where(confirmed: true) }

  accepts_nested_attributes_for :reservations
  accepts_nested_attributes_for :user

  after_update :send_details

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
    reservations.sum(:rent) * 0.3
  end

  def final_payment_amount
    reservations.sum(:rent) * 0.7
  end

  def step_passed?(step)
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
