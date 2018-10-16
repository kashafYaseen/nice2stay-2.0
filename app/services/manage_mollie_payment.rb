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
      return payment unless payment.status == 'expired'
    end

    payment = create_payment(booking.pre_payment, "PrePayment")
    booking.update_column :pre_payment_mollie_id, payment.id
    payment
  end

  def final_payment
    return if booking.final_payed_at?

    if booking.final_payment_mollie_id?
      payment = find_payment(booking.final_payment_mollie_id)
      return payment unless payment.status == 'expired'
    end

    payment = create_payment(booking.final_payment, "FinalPayment")
    booking.update_column :final_payment_mollie_id, payment.id
    payment
  end

  private
    def create_payment(amount, description)
      Mollie::Customer::Payment.create(
        customer_id:  user.mollie_id,
        amount:       { value: '10.00', currency: 'EUR' },
        description:  description,
        redirect_url: dashboard_url(host: 'localhost', port: 3000),
        metadata: [
          booking_id: booking.id,
          booking_reference: booking.identifier,
        ]
      )
    end

    def find_payment(id)
      Mollie::Payment.get(id)
    end
end
