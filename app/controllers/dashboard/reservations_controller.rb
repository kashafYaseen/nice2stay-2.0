class Dashboard::ReservationsController < DashboardController

  def index
    @reservations = current_user.reservations
  end
end
