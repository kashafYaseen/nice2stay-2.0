class SaveReservationDetails
  attr_reader :params
  attr_reader :reservation

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @reservation = Reservation.find_or_initialize_by(crm_booking_id: reservation_params[:crm_booking_id])
  end

  def call
    [reservation, save_reservation]
  end

  private
    def save_reservation
      reservation.user = user
      reservation.lodging = lodging
      reservation.attributes = reservation_params
      reservation.save(validate: false)
    end

    def user
      return unless params[:user].present?
      password = Devise.friendly_token[0, 20]
      User.where(email: user_params[:email]).first_or_create(user_params.merge(password: password, password_confirmation: password))
    end

    def lodging
      Lodging.find_by(slug: params[:reservation][:lodging_slug])
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
        :crm_booking_id,
        :skip_data_posting,
        :booking_status,
        :request_status,
      )
    end

    def user_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email
      )
    end
end
