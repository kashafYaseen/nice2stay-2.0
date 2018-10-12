class ReservationsController < ApplicationController
  before_action :set_booking_and_cookie, only: [:create]

  def create
    @reservation = @booking.reservations.build(reservation_params.merge(in_cart: true))
    if @reservation.save
      @reservation = @reservation.lodging.reservations.build
      @reservations = @booking.reservations
      flash.now[:notice] = "The lodging was successfully reserved."
    else
      @lodging = @reservation.lodging
      @reviews = @lodging.reviews.page(params[:page]).per(2)
    end
  end

  def validate
    @booking = @booking || Booking.new
    values = params[:values].split(',')
    @reservation = @booking.reservations.build(check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], lodging_id: values[5])
  end

  private
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_id, :adults, :children, :infants, :booking_status)
    end

    def set_booking_and_cookie
      return if @booking.present?
      @booking = Booking.create
      cookies[:booking] = @booking.id
    end
end
