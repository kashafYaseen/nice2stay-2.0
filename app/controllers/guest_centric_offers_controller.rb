class GuestCentricOffersController < ApplicationController
  before_action :set_lodging

  def show
    @guest_centric = GetGuestCentricOffers.call(@lodging, params[:reservation].merge(locale: locale))
    @reservation = @lodging.reservations.build(reservation_params)
  end

  def rates
    @guest_centric_rates, @total = GetGuestCentricRates.call(@lodging, params[:reservation])['response'], 0
    @guest_centric_rates.each { |rate| @total += rate['value'].to_f }
    @total += reservation_params[:meal_price].to_f
    @reservation = @booking.reservations.build(reservation_params.merge(in_cart: true, rent: @total))

    if params['button'] == 'cart'
      set_booking_and_cookie
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
      params.require(:reservation).permit(:check_in, :check_out, :lodging_id, :adults, :children, :infants, :offer_id, :meal_id, :meal_price)
    end

    def set_booking_and_cookie
      return if @booking.present?
      @booking = Booking.create
      cookies[:booking] = @booking.id
    end
end
