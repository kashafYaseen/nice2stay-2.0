class Api::V2::CartsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_booking

  def show
    render json: Api::V2::ReservationSerializer.new(@booking.reservations).serializable_hash.merge(booking_id: @booking.id), status: :ok
  end

  def create
    reservation = @booking.reservations.build(reservation_params.merge(in_cart: true))
    if reservation.save
      render json: Api::V2::ReservationSerializer.new(@booking.reservations).serializable_hash.merge(booking_id: @booking.id), status: :ok
    else
      unprocessable_entity(reservation.errors)
    end
  end

  def update
    @booking.attributes = booking_params.merge(uid: SecureRandom.uuid, pre_payment: @booking.pre_payment_amount, final_payment: @booking.final_payment_amount)
    if @booking.save
      @booking.reservations.guest_centric.each do |reservation|
        BookGuestCentricOffer.call(reservation.lodging, reservation, @booking)
      end

      @booking.reservations.room_raccoon.includes(room_rate: %i[room_type rate_plan]).each do |reservation|
        RoomRaccoons::SendReservations.call(reservation: reservation)
      end

      @booking.reservations_open_gds.includes(room_rate: %i[room_type rate_plan child_rates]).each do |reservation|
        OpenGds::SendReservations.call(reservation: reservation)
      end

      render json: Api::V2::BookingSerializer.new(@booking, { params: { reservations: true, auth: true } }).serialized_json, status: :ok
    else
      unprocessable_entity(@booking.errors)
    end
  end

  def destroy
    @booking.reservations.delete_all
    render json: Api::V2::ReservationSerializer.new(@booking.reservations).serializable_hash.merge(booking_id: @booking.id), status: :ok
  end

  def remove
    @booking.reservations.find_by(id: params[:reservation_id]).try(:delete)
    render json: Api::V2::ReservationSerializer.new(@booking.reservations.reload).serializable_hash.merge(booking_id: @booking.id), status: :ok
  end

  private
    def reservation_params
      params.require(:reservation).permit(
        :check_in,
        :check_out,
        :lodging_id,
        :adults,
        :children,
        :infants,
        :booking_status,
        :cleaning_cost,
        :discount,
        :meal_tax,
        :tax,
        :additional_fee,
        :room_type,
        :rooms,
        :gc_errors,
        :gc_policy,
        :guest_centric_booking_id,
        :meal_id,
        :offer_id,
        :rent,
        :meal_price,
        :room_rate_id,
      )
    end

    def booking_params
      params.require(:booking).permit(
        :in_cart,
        :created_by,
        user_attributes: [:id, :first_name, :last_name, :email, :password, :password_confirmation, :creation_status, :country_id, :city, :zipcode, :address, :phone, :skip_validations, :language],
        reservations_attributes: [:id, :booking_id, :in_cart]
      )
    end

    def set_booking
      @booking = Booking.find_by(id: params[:booking_id], in_cart: true)

      if current_user.present?
        if @booking.present? && @booking != current_user.booking_in_cart
          @booking.reservations.update_all(booking_id: current_user.booking_in_cart.id) if @booking.reservations.present?
          @booking.delete
        end
        @booking = current_user.booking_in_cart
      end
      @booking ||= Booking.create
    end
end
