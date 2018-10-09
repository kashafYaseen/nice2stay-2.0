class Dashboard::ReservationsController < DashboardController
  def index
    @title = 'Reservations'
    add_breadcrumb @title, dashboard_reservations_path

    @bookings = current_user.bookings_confirmed.includes(:reservations).page(params[:bookings_page]).per(5)
    @requests = current_user.reservations_non_confirmed.includes(lodging: :translations).page(params[:requests_page]).per(5)
    @options = current_user.reservations_confirmed_options.includes(lodging: :translations).page(params[:options_page]).per(5)
  end
end
