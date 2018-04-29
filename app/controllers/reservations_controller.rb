class ReservationsController < ApplicationController
  before_action :authenticate_user!

  def create
    if current_user.reservations.create(reservation_params)
      flash[:notice] = "The lodging was successfully reserved."
    else
      flash[:alert] = "Something went wrong"
    end
    redirect_to root_path
  end

  private


    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_id)
    end
end
