class Dashboard::BookingsController < DashboardController
  def show
    @booking = current_user.bookings.find(params[:id])

    @title = @booking.identifier
    add_breadcrumb 'Reservations', dashboard_reservations_path
    add_breadcrumb @title
  end
end
