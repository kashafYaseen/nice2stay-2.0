class Dashboard::ReservationsController < DashboardController
  before_action :set_option, except: [:index]

  def index
    @title = 'Reservations'
    add_breadcrumb @title, dashboard_reservations_path

    @old_bookings = current_user.bookings_confirmed.old.includes(:reservations).page(params[:old_bookings_page]).per(5)
    @upcoming_bookings = current_user.bookings_confirmed.upcoming.includes(:reservations).page(params[:upcoming_bookings_page]).per(5)
    @requests = current_user.reservations_non_confirmed.includes(lodging: :translations).page(params[:requests_page]).per(5)
    @options = current_user.reservations_confirmed_options.includes(lodging: :translations).page(params[:options_page]).per(5)
  end

  def destroy
    @option.destroy
    redirect_to dashboard_reservations_path, notice: 'Option was removed successfully'
  end

  def accept_option
    if @option.update_columns(booking_status: :prebooking, book_option: :customer)
      SendBookingDetailsJob.perform_now(@option.booking_id)
      redirect_to dashboard_booking_path(@option.booking_id), notice: t('reservations.option_converted_success')
    else
      redirect_to dashboard_booking_path(@option.booking_id), notice: 'Unable to process your request at the moment.'
    end
  end

  def cancel_option
    if @option.update_columns(request_status: :canceled, canceled: true)
      SendBookingDetailsJob.perform_now(@option.booking_id)
      redirect_to dashboard_reservations_path, notice: t('reservations.option_cancelation_success')
    else
      redirect_to dashboard_reservations_path, notice: 'Unable to process your request at the moment.'
    end
  end

  private
    def set_option
      @option = current_user.reservations_confirmed_options.find(params[:id])
    end
end
