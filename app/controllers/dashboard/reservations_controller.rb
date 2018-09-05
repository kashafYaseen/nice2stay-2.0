class Dashboard::ReservationsController < DashboardController
  def index
    @title = 'Reservations'
    add_breadcrumb @title, dashboard_reservations_path
    @reservations = current_user.reservations.requests
  end
end
