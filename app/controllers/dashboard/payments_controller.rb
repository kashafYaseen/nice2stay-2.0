class Dashboard::PaymentsController < DashboardController
  def create
    if params[:payment] == 'pre-payment'
      payment = ManageMolliePayment.new(current_user.bookings.find(params[:booking_id])).pre_payment
    elsif params[:payment] == 'final-payment'
      payment = ManageMolliePayment.new(current_user.bookings.find(params[:booking_id])).final_payment
    end
    return redirect_to payment._links['checkout']['href'] if payment.present?
    redirect_to dashboard_reservation_path(locale: locale), alert: "Unable to process your request at the moment."
  end
end
