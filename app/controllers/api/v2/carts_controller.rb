class Api::V2::CartsController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_booking

  def show
    render json: Api::V2::ReservationSerializer.new(@booking.reservations).serialized_json, status: :ok
  end

  def create
    reservation = @booking.reservations.build(reservation_params.merge(in_cart: true))
    if reservation.save
      render json: Api::V2::ReservationSerializer.new(@booking.reservations).serialized_json, status: :ok
    else
      unprocessable_entity(reservation.errors)
    end
  end

  def destroy
    @booking.reservations.delete_all
    render json: Api::V2::ReservationSerializer.new(@booking.reservations).serialized_json, status: :ok
  end

  def remove
    @booking.reservations.find_by(id: params[:reservation_id]).try(:delete)
    render json: Api::V2::ReservationSerializer.new(@booking.reservations.reload).serialized_json, status: :ok
  end

  private
    def reservation_params
      params.require(:reservation).permit(:check_in, :check_out, :lodging_id, :adults, :children, :infants, :booking_status, :cleaning_cost, :discount)
    end

    def set_booking
      @booking = current_user.booking_in_cart
    end
end
