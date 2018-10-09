class Dashboard::BookingsController < DashboardController
  def show
    @booking = current_user.bookings.find(params[:id])
  end
end
