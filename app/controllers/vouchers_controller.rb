class VouchersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:update_status]

  def new
    @voucher = Voucher.new(amount: 0)
    @voucher.build_receiver
  end

  def create
    @voucher = Voucher.new(voucher_params)
    if @voucher.save
      if @voucher.amount > Voucher::PREDEFINED_GIFT_AMOUNT
        payment = VoucherPayment.new(voucher: @voucher, params: { locale: locale }).voucher_payment
        return redirect_to mollie_payment_url(payment, params[:payment]) if payment.present?
      else
        # redirect_to root_path(locale: locale), notice: 'Voucher was created successfully.'
        redirect_to voucher_path(@voucher, locale: locale), notice: 'Voucher was created successfully.'
      end
    else
      render :new
    end
  end

  def show
    @voucher = Voucher.find(params[:id])
  end

  def update_status
    @voucher = Voucher.find(params[:voucher_id])
    VoucherPayment.new(voucher: @voucher).update_status(params[:id])
    render status: 200, json: { status: :ok }
  end

  private
    def voucher_params
      params.require(:voucher).permit(
        :sender_name,
        :sender_email,
        :send_by_post,
        :message,
        :amount,
        :receiver_city,
        :receiver_country_id,
        :receiver_zipcode,
        :receiver_address,
        :terms_and_conditions,
        receiver_attributes: [:first_name, :last_name, :email]
      )
    end

    def mollie_payment_url(payment, type)
      return payment._links['checkout']['href'] if payment._links['checkout'].present? && payment._links['checkout']['href'].present?
      @payment_booking.update_columns(mollie_payment_id: nil)
      voucher_path(locale: locale)
    end
end
