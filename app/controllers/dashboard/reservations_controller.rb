class Dashboard::ReservationsController < DashboardController
  def index
    @title = 'Reservations'
    add_breadcrumb @title, dashboard_reservations_path
    @requests = current_user.requests_pending_or_rejected.includes(lodging: :translations).page(params[:requests_page]).per(5)
    @bookings = current_user.requests_confirmed.includes(lodging: :translations).page(params[:bookings_page]).per(5)
    @bookings_requests = current_user.bookings.requests
  end
end
