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
    return if booking.pre_payment_mollie_id?
    payment = create_payment(booking.pre_payment, "PrePayment")
    booking.update_column pre_payment_mollie_id: payment.id
  end

  def final_payment
    return if booking.final_payment_mollie_id?
    payment = create_payment(booking.final_payment, "FinalPayment")
    booking.update_column final_payment_mollie_id: payment.id
  end

  private
    def create_payment(amount, description)
      Mollie::Customer::Payment.create(
        customer_id:  user.mollie_id,
        amount:       { value: amount.round(2).to_s, currency: 'EUR' },
        description:  description,
        method: 'creditcard',
        redirect_url: dashboard_url(host: 'localhost', port: 3000),
        metadata: [
          booking_id: booking.id,
          booking_reference: booking.identifier,
        ]
      )
    end
end
