class VoucherPayment
  include Rails.application.routes.url_helpers

  attr_reader :voucher, :params

  def initialize(voucher:, params: {})
    @voucher = voucher
    @params = params
    @mollie = VoucherMollieCustomer.new(voucher: voucher, sender: sender)
  end

  def voucher_payment
    if voucher.mollie_payment_id?
      payment = find_payment(voucher.mollie_payment_id)
      return update_redirect_url(payment) if payment.status == 'open'
    end

    payment = create_payment(voucher.mollie_amount, "#{voucher.code} - Voucher Payment")
    voucher.update_column :mollie_payment_id, payment.id
    payment
  end

  def update_status(payment_id)
    payment = find_payment(payment_id)
    return remove_rejected(payment) unless payment.status == 'paid'
    voucher.update_columns payed_at: payment.paid_at, payment_status: payment.status
    SendVoucherDetailsJob.perform_later(voucher.id)
  end

  private
    def sender
      {
        email: voucher.sender_email,
        full_name: voucher.sender_name,
        mollie_id: voucher.sender_mollie_id,
      }
    end

    def create_payment(amount, description)
      Mollie::Customer::Payment.create(
        customer_id:    sender[:mollie_id],
        amount:         { value: ("%.2f" % amount.round(2)), currency: 'EUR' },
        description:    description,
        redirect_url:   redirect_url,
        webhook_url:    webhook_url,
        metadata: {
          voucher_id:   voucher.id,
          voucher_code: voucher.code,
        }
      )
    end

    def remove_rejected(payment)
      return unless payment.status == 'failed' || payment.status == 'expired' || payment.status == 'canceled'
      voucher.update_column(:mollie_payment_id, nil)
    end

    def find_payment(id)
      Mollie::Payment.get(id)
    end

    def webhook_url
      return voucher_update_status_url(voucher_id: voucher, locale: params[:locale], host: ENV['CLIENT_BASE_URL']) if Rails.env.production?
      voucher_update_status_url(voucher_id: voucher, locale: params[:locale], host: 'https://cc40-124-109-59-230.ngrok.io') # host could be localhost
    end

    def update_redirect_url(payment)
      payment.update(redirect_url: redirect_url) unless payment.redirect_url == redirect_url
      payment
    end

    def redirect_url
      return voucher_url(voucher, code: voucher.code, locale: params[:locale], host: ENV['CLIENT_BASE_URL']) if Rails.env.production?
      voucher_url(voucher, code: voucher.code, locale: params[:locale], host: 'https://cc40-124-109-59-230.ngrok.io') # host could be localhost
    end
end
