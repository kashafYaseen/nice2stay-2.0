class BookingExpertLodgingsController < ApplicationController
  before_action :set_lodging
  before_action :set_booking_and_cookie, only: [:rates]

  def show
    @be_availabilities = GetBookingExpertAvailabilities.call(@lodging, params[:reservation])
    @reservation = @lodging.reservations.build(reservation_params)
  end

  def rates
    @reservation = @booking.reservations.build(reservation_params.merge(in_cart: true))
    @reservation.total_price = @reservation.rent + @reservation.additional_fee

    if params['button'] == 'cart'
      @reservation.save(validate: false)
      @reservation = @reservation.lodging.reservations.build
      @reservations = @booking.reservations
    end
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
      @lodging = @lodging.parent if @lodging.parent.present?
    end

    def reservation_params
      params.require(:reservation).permit(
        :check_in,
        :check_out,
        :lodging_id,
        :be_category_id,
        :adults,
        :children,
        :infants,
        :offer_id,
        :meal_id,
        :meal_price,
        :rent,
        :rooms,
        :meal_tax,
        :tax,
        :additional_fee,
        :room_type,
        :gc_policy,
      )
    end

    def set_booking_and_cookie
      return if @booking.present?
      @booking = Booking.create
      cookies[:booking] = @booking.id
    end
end
