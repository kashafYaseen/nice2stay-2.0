class Api::V1::VouchersController < Api::V1::ApiController
  def create
    voucher = Voucher.find_or_initialize_by(crm_id: voucher_params[:crm_id])
    voucher.attributes = voucher_params
    if voucher.save
      render json: { success: true }, status: :created
    else
      unprocessable_entity(voucher.errors)
    end

    puts voucher.errors.full_messages
  end

  private
    def voucher_params
      params.require(:voucher).permit(
        :crm_id,
        :sender_name,
        :sender_email,
        :amount,
        :send_by_post,
        :message,
        :receiver_city,
        :receiver_zipcode,
        :receiver_address,
        :code,
        :used,
        :expired_at,
        :receiver_country_id,
        :payment_status,
        :payed_at,
        :mollie_amount,
        :created_by,
        :skip_data_posting,
        receiver_attributes: [:first_name, :last_name, :email, :country_id, :city, :zipcode, :address],
      )
    end
end
