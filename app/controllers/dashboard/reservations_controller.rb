class Dashboard::ReservationsController < DashboardController
  def index
    @title = 'Reservations'
    add_breadcrumb @title, dashboard_reservations_path
    @requests = current_user.requests_pending_or_rejected.includes(lodging: :translations)
    @bookings = current_user.requests_confirmed.includes(lodging: :translations)
  end
end
