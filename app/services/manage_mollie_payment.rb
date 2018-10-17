class ManageMolliePayment
  include Rails.application.routes.url_helpers

  attr_reader :booking
  attr_reader :user

  def initialize(booking)
    @booking = booking
    @mollie = ManageMollieCustomer.new(booking.user)
    @user = @mollie.user
  end

  def pre_payment
    return if booking.pre_payed_at?

    if booking.pre_payment_mollie_id?
      payment = find_payment(booking.pre_payment_mollie_id)
      return payment if payment.status == 'open'
    end

    payment = create_payment(booking.pre_payment, "Pre-Payment")
    booking.update_column :pre_payment_mollie_id, payment.id
    payment
  end

  def final_payment
    return if booking.final_payed_at?

    if booking.final_payment_mollie_id?
      payment = find_payment(booking.final_payment_mollie_id)
      return payment if payment.status == 'open'
    end

    payment = create_payment(booking.final_payment, "Final-Payment")
    booking.update_column :final_payment_mollie_id, payment.id
    payment
  end

  def update_status(payment_id)
    payment = find_payment(payment_id)
    return remove_rejected(payment) unless payment.status == 'paid'
    booking.update_column(:pre_payed_at, payment.paid_at) if payment.id == booking.pre_payment_mollie_id
    booking.update_column(:final_payed_at, payment.paid_at) if payment.id == booking.final_payment_mollie_id
  end

  def get_pre_payment
    return unless booking.pre_payment_mollie_id?
    find_payment(booking.pre_payment_mollie_id)
  end

  def get_final_payment
    return unless booking.final_payment_mollie_id?
    find_payment(booking.final_payment_mollie_id)
  end

  private
    def create_payment(amount, description)
      amount = '10.00' unless amount > 0 # FIXME
      Mollie::Customer::Payment.create(
        customer_id:  user.mollie_id,
        amount:       { value: amount, currency: 'EUR' },
        description:  description,
        redirect_url: redirect_url,
        webhookUrl:   webhook_url,
        metadata: [
          booking_id: booking.id,
          booking_reference: booking.identifier,
        ]
      )
    end

    def remove_rejected(payment)
      return unless payment.status == 'failed' || payment.status == 'expired' || payment.status == 'canceled'
      booking.update_column(:pre_payment_mollie_id, nil) if payment.id == booking.pre_payment_mollie_id
      booking.update_column(:final_payment_mollie_id, nil) if payment.id == booking.final_payment_mollie_id
    end

    def find_payment(id)
      Mollie::Payment.get(id)
    end

    def webhook_url
      return update_status_dashboard_booking_payment_url(booking_id: booking, host: ENV['CLIENT_BASE_URL']) if Rails.env.production?
      'http://6d520d52.ngrok.io'
    end

    def redirect_url
      return dashboard_booking_payment_url(booking_id: booking, host: ENV['CLIENT_BASE_URL']) if Rails.env.production?
      dashboard_booking_payment_url(booking_id: booking, host: 'localhost', port: 3000)
    end
end
