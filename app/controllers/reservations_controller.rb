class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def create
    @reservation = current_user.reservations.new(reservation_params)
    if @reservation.save
      redirect_to lodging_path(@reservation.lodging_id), notice: "The lodging was successfully reserved."
    else
      @lodging = @reservation.lodging
      render 'lodgings/show'
    end
  end

  private
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_id, :adults, :children, :infants)
    end
end
