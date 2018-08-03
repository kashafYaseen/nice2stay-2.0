class Api::V1::ReservationsController < Api::V1::ApiController
  before_action :set_reservation, only: [:show, :update]

  def show
    return not_acceptable("Reservation not found") unless @reservation.present?
  end

  def create
    @reservation, result = SaveReservationDetails.call(params)

    if result
      render status: :created
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  def update
    if @reservation.update(reservation_params)
      render status: :ok
    else
      render json: @reservation.errors, status: :unprocessable_entity
    end
  end

  private
    def set_reservation
      @reservation = Reservation.find_by(id: params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(
        :lodging_id,
        :user_id,
        :check_in,
        :check_out,
        :adults,
        :children,
        :infants,
        :total_price,
        :rent,
        :discount,
        :cleaning_cost,
        :skip_data_posting
      )
    end
end
