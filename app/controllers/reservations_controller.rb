class ReservationsController < ApplicationController
  before_action :set_booking, only: [:create]

  def create
    @reservation = @booking.reservations.build(reservation_params.merge(in_cart: true, user: current_user))
    if @reservation.save
      @reservations = @booking.reservations unless current_user.present?
      flash.now[:notice] = "The lodging was successfully reserved."
    else
      @lodging = @reservation.lodging
      @reviews = @lodging.reviews.page(params[:page]).per(2)
    end
  end

  def validate
    values = params[:values].split(',')
    @reservation = Reservation.new(check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], lodging_id: values[5])
  end

  private
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_id, :adults, :children, :infants, :booking_status)
    end

    def set_booking
      return @booking = current_user.booking_in_cart if current_user.present?
      @booking = Booking.find_by(id: cookies[:booking]) || Booking.create
      cookies[:booking] = @booking.id
    end
end
