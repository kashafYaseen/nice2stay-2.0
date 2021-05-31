class Api::V2::PaymentsController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_booking, except: [:payment_method_details]

  def create
    if params[:payment] == 'pre-payment'
      payment = ManageMolliePayment.new(@booking, params).pre_payment
    elsif params[:payment] == 'final-payment'
      payment = ManageMolliePayment.new(@booking, params).final_payment
    end

    if payment.present?
      render json: { url: mollie_payment_url(payment, params[:payment]) }, status: :created
    else
      unprocessable_entity("Unable to process your request at the moment.")
    end
  end

  def payment_method_details
    details = Mollie::Method.get(params[:payment_method], include: 'issuers')

    if details.present?
      render json: { details: mollie_payment_method_details(details) }, status: :ok
    else
      unprocessable_entity("Unable to process your request at the moment.")
    end
  end

  def payment_status
    if params[:payment] == 'pre-payment'
      payment = ManageMolliePayment.new(@booking).get_pre_payment
    elsif params[:payment] == 'final-payment'
      payment = ManageMolliePayment.new(@booking).get_final_payment
    end

    render json: { status: payment.present? ? payment.status : false }, status: :ok
  end

  private
    def set_booking
      @booking = current_user.bookings.find(params[:booking_id])
    end

    def mollie_payment_url(payment, type)
      return payment._links['checkout']['href'] if payment._links['checkout'].present? && payment._links['checkout']['href'].present?
      @booking.update_columns pre_payment_mollie_id: nil if type == 'pre-payment'
      @booking.update_columns final_payment_mollie_id: nil if type == 'final-payment'
    end

    def mollie_payment_method_details(details)
      details.issuers.map { |issuer| { id: issuer['id'], name: issuer['name'], images: issuer['image'] } }
    end
end
