class Api::V2::PaymentsController < Api::V2::ApiController
  include MollieCredentials
  before_action :authenticate
  before_action :set_booking, except: [:payment_method_details, :payment_methods]

  def create
    if params[:payment] == 'pre-payment'
      payment = ManageMolliePayment.new(@booking, params).pre_payment
    elsif params[:payment] == 'final-payment'
      payment = ManageMolliePayment.new(@booking, params).final_payment
    elsif params[:payment] == 'security-deposit'
      payment = ManageMolliePayment.new(@booking, params).security_deposit_payment
    end

    if payment.present?
      render json: { url: mollie_payment_url(payment, params[:payment]), status: payment.status }, status: :created
    else
      unprocessable_entity("Unable to process your request at the moment.")
    end
  end

  def payment_methods
    methods = Mollie::Method.all(api_key: api_key(params[:requesting_site]))
    render json: { methods: methods.map { |method| { id: method.id, description: method.description, images: method.image, status: method.attributes['status'] } } }, status: :ok
  end

  def payment_method_details
    details = Mollie::Method.get(params[:payment_method], api_key: api_key(params[:requesting_site]), include: 'issuers')

    if details.present?
      render json: { details: mollie_payment_method_details(details) }, status: :ok
    else
      unprocessable_entity("Unable to process your request at the moment.")
    end
  end

  def update_status
    if params[:payment] == 'pre-payment'
      ManageMolliePayment.new(@booking).update_status(@booking.pre_payment_mollie_id)
    elsif params[:payment] == 'final-payment'
      ManageMolliePayment.new(@booking).update_status(@booking.final_payment_mollie_id)
    elsif params[:payment] == 'security-deposit'
      ManageMolliePayment.new(@booking).update_status(@booking.security_deposit_payment_mollie_id)
    end

    render json: Api::V2::BookingSerializer.new(@booking).serialized_json, status: :ok
  end

  private
    def set_booking
      @booking = current_user.bookings.find(params[:booking_id])
    end

    def mollie_payment_url(payment, type)
      return if payment.status == 'paid'
      return payment._links['checkout']['href'] if payment._links['checkout'].present? && payment._links['checkout']['href'].present?
      @booking.update_columns pre_payment_mollie_id: nil if type == 'pre-payment'
      @booking.update_columns final_payment_mollie_id: nil if type == 'final-payment'
      @booking.update_columns security_deposit_payment_mollie_id: nil if type == 'security-payment'
    end

    def mollie_payment_method_details(details)
      details.issuers.map { |issuer| { id: issuer['id'], name: issuer['name'], images: issuer['image'] } }
    end
end
