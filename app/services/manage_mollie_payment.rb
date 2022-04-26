class ManageMolliePayment
  include Rails.application.routes.url_helpers
  include MollieCredentials

  attr_reader :booking,
              :user,
              :redirect_custom_url,
              :issuer,
              :card_token,
              :params

  def initialize(booking, params = nil)
    @booking = booking
    @mollie = ManageMollieCustomer.new(booking.user, params)
    @user = @mollie.user
    @params = params
    @issuer = {}
    if params.present?
      @redirect_custom_url = params[:redirect_url]
      @issuer = params[:issuer] || {}
      @card_token = params[:card_token]
    end
  end

  def pre_payment
    return if booking.pre_payed_at?

    if booking.pre_payment_mollie_id?
      payment = find_payment(booking.pre_payment_mollie_id)
      return update_redirect_url(payment) if payment.status == 'open'
    end

    payment = create_payment(pre_payment_amount, "#{booking.identifier} - Pre Payment")
    booking.update_column :pre_payment_mollie_id, payment.id
    payment
  end

  def final_payment
    return if booking.final_payed_at?

    if booking.final_payment_mollie_id?
      payment = find_payment(booking.final_payment_mollie_id)
      return update_redirect_url(payment) if payment.status == 'open'
    end

    payment = create_payment(final_payment_amount, "#{booking.identifier} - Final Payment")
    booking.update_column :final_payment_mollie_id, payment.id
    payment
  end

  def security_deposit_payment
    return if booking.security_payed_at?

    if booking.security_deposit_payment_mollie_id?
      payment = find_payment(booking.security_deposit_payment_mollie_id)
      return update_redirect_url(payment) if payment.status == 'open'
    end

    payment = create_payment(security_deposit_amount, "#{booking.identifier} - Security deposit Payment")
    booking.update_column :security_deposit_payment_mollie_id, payment.id
    payment
  end

  def update_status(payment_id)
    payment = find_payment(payment_id)
    return remove_rejected(payment) unless payment.status == 'paid'

    booking.pre_paid_at! payment.paid_at if payment.id == booking.pre_payment_mollie_id
    booking.final_paid_at! payment.paid_at if payment.id == booking.final_payment_mollie_id
    booking.security_paid_at! payment.paid_at if payment.id == booking.security_deposit_payment_mollie_id
  end

  def get_pre_payment
    return unless booking.pre_payment_mollie_id?

    find_payment(booking.pre_payment_mollie_id)
  end

  def get_final_payment
    return unless booking.final_payment_mollie_id?

    find_payment(booking.final_payment_mollie_id)
  end

  def get_security_payment
    return unless booking.security_deposit_payment_mollie_id?

    find_payment(booking.security_deposit_payment_mollie_id)
  end

  private
    def create_payment(amount, description)
      Mollie::Customer::Payment.create(
        api_key: api_key(params.present? && params[:requesting_site]),
        customer_id:  user.mollie_id,
        amount:       { value: ("%.2f" % amount.round(2)), currency: 'EUR' },
        description:  description,
        redirect_url: redirect_url,
        webhook_url:   webhook_url,
        issuer: issuer[:id],
        method: issuer[:method],
        card_token: card_token,
        metadata: {
          booking_id: booking.id,
          booking_reference: booking.identifier,
        }
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
      "http://6155492f.ngrok.io?booking_id=#{booking.id}"
    end

    def update_redirect_url(payment)
      payment.update(redirect_url: redirect_url) unless payment.redirect_url == redirect_url
      payment
    end

    def redirect_url
      return redirect_custom_url if redirect_custom_url.present?
      return dashboard_booking_url(booking, host: ENV['CLIENT_BASE_URL']) if Rails.env.production?
      dashboard_booking_url(booking, host: 'localhost', port: 3000)
    end

    def pre_payment_amount
      booking.pre_payment > 0 ? booking.pre_payment : booking.pre_payment_amount
    end

    def final_payment_amount
      booking.final_payment > 0 ? booking.final_payment : booking.final_payment_amount
    end

    def security_deposit_amount
      booking.security_deposit_payment > 0 ? booking.security_deposit_payment : booking.security_deposit_amount
    end
end
