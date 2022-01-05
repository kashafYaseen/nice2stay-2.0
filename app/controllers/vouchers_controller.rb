class VouchersController < ApplicationController
  def new
    @voucher = Voucher.new(amount: 0)
    @voucher.build_receiver
  end

  def create
    @voucher = Voucher.new(voucher_params)
    if @voucher.save
      redirect_to root_path(locale: locale), notice: 'Voucher was created successfully.'
    else
      render :new
    end
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
end
