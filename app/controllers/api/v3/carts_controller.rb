class Api::V3::CartsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_booking

  def show
    render json: Api::V2::BookingSerializer.new(@booking, { params: { reservations: true } }).serialized_json, status: :ok
  end

  private
    def set_booking
      @booking = Booking.find_by(id: params[:booking_id], in_cart: true)

      if current_user.present?
        if @booking.present? && @booking != current_user.booking_in_cart
          @booking.reservations.update_all(booking_id: current_user.booking_in_cart.id) if @booking.reservations.present?
          @booking.delete
        end
        @booking = current_user.booking_in_cart
      end
    end
end
