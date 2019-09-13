class CartsController < ApplicationController
  before_action :empty_cart, only: [:remove, :destroy, :update]
  before_action :set_booking_and_cookie, only: [:show]
  before_action :set_user, only: [:update]
  before_action :set_booking_details, only: [:details]

  def show
    @guest_centric = @booking.reservations.guest_centric.present?
    @booking.build_user(creation_status: :without_login) unless @booking.user.present?
  end

  def remove
    @booking.reservations.find_by(id: params[:reservation_id]).try(:delete)
    @reservations = @booking.reservations.reload
    flash.now[:notice] = 'Reservation was removed successfully.'
  end

  def update
    @guest_centric = @booking.reservations.guest_centric.present?
    @booking.attributes = booking_params.merge(uid: SecureRandom.uuid, pre_payment: @booking.pre_payment_amount, final_payment: @booking.final_payment_amount)
    if @booking.save
      @booking.reservations.guest_centric.each do |reservation|
        BookGuestCentricOffer.call(reservation.lodging, reservation, @booking)
      end

      cookies[:booking_details] = @booking.id
      redirect_to details_carts_path, notice: 'Booking was created successfully.'
    else
      render :show
    end
  end

  def destroy
    @booking.reservations.delete_all
    redirect_to carts_path, notice: 'Cart was cleared successfully.'
  end

  def details
    @user = @booking_details.user
  end

  private
    def empty_cart
      return redirect_to carts_path unless @booking.present? && @booking.in_cart && @booking.reservations.present?
    end

    def set_user
      return if params[:create_account].present? || current_user.present?
      @booking.user = User.without_login.find_by(email: booking_params[:user_attributes][:email])
    end

    def set_password
      return if params[:create_account].present?
      user = User.without_login.find_by(email: booking_params[:user_attributes][:email])
      if user.present?
        user.attributes = booking_params[:user_attributes]
        user.save
        return @booking.user = user
      end
      @booking.user.password = @booking.user.password_confirmation = Devise.friendly_token[0, 20]
    end

    def booking_params
      params.require(:booking).permit(
        :in_cart,
        user_attributes: [:id, :first_name, :last_name, :email, :password, :password_confirmation, :creation_status, :country_id, :city, :zipcode, :address, :phone, :skip_validations, :language],
        reservations_attributes: [:id, :booking_id, :in_cart]
      )
    end

    def set_booking_and_cookie
      return if @booking.present?
      @booking = Booking.create
      cookies[:booking] = @booking.id
    end

    def set_booking_details
      @booking_details = Booking.find_by(id: cookies[:booking_details])
      return redirect_to carts_path unless @booking_details.present?
    end
end
