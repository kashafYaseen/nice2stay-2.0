class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @reservation = current_user.reservations.new(reservation_params.merge(booking_status: :in_cart))
    if @reservation.save
      redirect_to lodging_path(@reservation.lodging), notice: "The lodging was successfully reserved."
    else
      @lodging = @reservation.lodging
      @reviews = @lodging.reviews.page(params[:page]).per(2)
      render 'lodgings/show'
    end
  end

  def validate
    values = params[:values].split(',')
    @reservation = current_user.reservations.new(check_in: values[0], check_out: values[1], adults: values[2], children: values[3], infants: values[4], lodging_child_id: values[5])
  end

  private
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_child_id, :adults, :children, :infants)
    end
end
