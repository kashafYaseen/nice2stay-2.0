class CartsController < ApplicationController
  before_action :empty_cart, only: [:remove, :destroy, :update]
  before_action :set_booking_and_cookie, only: [:show]
  before_action :set_user, only: [:update]
  before_action :set_booking_details, only: [:details]

  def show
    @channel_manager = @booking.reservations.guest_centric.present? || @booking.reservations.booking_expert.present?
    @guest_centric = @booking.reservations.guest_centric.present?
    @reservations = @booking.reservations.unexpired
    # to_i will cast nil to 0 which mitigates nil errors when children will be nil
    @reservations.map { |reservation| reservation.children.to_i.times.each { reservation.guest_details.build } }
    @reservations.map { |reservation| reservation.adults.to_i.times.each { reservation.guest_details.build } }
    @booking.build_user(creation_status: :without_login) unless @booking.user.present?
  end

  def remove
    @booking.reservations.unexpired.find_by(id: params[:reservation_id]).try(:delete)
    @reservations = @booking.reservations.unexpired.reload
    flash.now[:error] = 'Accommodation was removed successfully.'
  end

  def update
    @channel_manager = @booking.reservations.guest_centric.present? || @booking.reservations.booking_expert.present?
    @booking.attributes = booking_params.merge(uid: SecureRandom.uuid, pre_payment: @booking.pre_payment_amount, final_payment: @booking.final_payment_amount)

    if @booking.voucher_code.present?
      voucher = Voucher.find_by(code: @booking.voucher_code)
      if voucher.blank? || voucher.not_available?
        @booking.errors.add(:base, I18n.t('vouchers.error'))
        return
      end
    end

    if @booking.save
      @booking.reservations.guest_centric.each { |reservation| BookGuestCentricOffer.call(lodging_parent_if_exist(reservation), reservation, @booking) }
      @booking.reservations.booking_expert.each { |reservation| ReserveBookingExpertLodging.call(lodging_parent_if_exist(reservation), reservation) }

      SendBookingDetailsJob.perform_later(@booking.id)

      cookies[:booking_details] = @booking.id
      flash[:notice] = I18n.t('bookings.created', identifier: @booking.identifier, link: dashboard_reservations_path)
      flash[:success] = I18n.t('bookings.voucher_added', code: @booking.voucher_code) if @booking.present? && @booking.voucher_code.present?
      redirect_to details_carts_path
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
        :in_cart, :voucher_code,
        user_attributes: [:id, :first_name, :last_name, :email, :password, :password_confirmation, :creation_status, :country_id, :city, :zipcode, :address, :phone, :skip_validations, :language],
        reservations_attributes: [:id, :booking_id, :in_cart, :skip_data_posting, guest_details_attributes: [:id, :age, :name, :guest_type]],
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

    def lodging_parent_if_exist reservation
      return reservation.lodging_parent if reservation.lodging.as_child?
      reservation.lodging
    end
end
