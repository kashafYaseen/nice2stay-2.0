class ReservationsController < ApplicationController
  def create
    @reservation = Reservation.new(reservation_params.merge(in_cart: true, user: current_user))
    if @reservation.save
      save_cart_items unless current_user.present?
      flash.now[:notice] = "The lodging was successfully reserved."
    else
      @lodging = @reservation.lodging
      @reviews = @lodging.reviews.page(params[:page]).per(2)
    end
  end

  def validate
    values = params[:values].split(',')
    @reservation = Reservation.new(check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], lodging_child_id: values[5])
  end

  private
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_child_id, :adults, :children, :infants, :booking_status)
    end

    def save_cart_items
      if cookies[:reservations].present?
        cookies[:reservations] += ",#{@reservation.id}"
      else
        cookies[:reservations] = @reservation.id.to_s
      end
      @reservations = Reservation.where(id: cookies[:reservations].split(','))
    end
end
