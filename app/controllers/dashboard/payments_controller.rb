class Dashboard::PaymentsController < DashboardController
  skip_before_action :verify_authenticity_token, :authenticate_user!, only: [:update_status]
  before_action :set_payment_booking

  def create
    if params[:payment] == 'pre-payment'
      payment = ManageMolliePayment.new(@payment_booking).pre_payment
    elsif params[:payment] == 'final-payment'
      payment = ManageMolliePayment.new(@payment_booking).final_payment
    end
    return redirect_to payment._links['checkout']['href'] if payment.present?
    redirect_to dashboard_reservation_path(locale: locale), alert: "Unable to process your request at the moment."
  end

  def update_status
    ManageMolliePayment.new(@payment_booking).update_status(params[:id])
    render status: 200, json: { status: :ok }
  end

  private
    def set_payment_booking
      return @payment_booking = Booking.find(params[:booking_id]) unless current_user.present?
      @payment_booking = current_user.bookings.find(params[:booking_id])
    end
end
