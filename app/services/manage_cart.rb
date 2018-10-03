class ManageCart
  attr_reader :reservations
  attr_reader :user
  attr_reader :cookies

  def initialize(reservations:, user:, cookies:)
    @reservations = reservations
    @user = user
    @cookies = cookies
  end

  def delete(reservation_id)
    reservations.find_by_id(reservation_id).try(:delete)
    set_reservations
    update_cookies if cookies[:reservations].present?
    reservations
  end

  def checkout(signed_in)
    errors = {}
    reservations.each do |reservation|
      if reservation.update(user: user, in_cart: false, booking_status: booking_status(reservation))
        remove_cookie(reservation.id) unless signed_in
      else
        errors[reservation.lodging_name] = reservation.errors
      end
    end
    errors
  end

  private
    def set_reservations
      return @reservations = user.reservations_in_cart if user.present?
      @reservations = Reservation.where(id: cookies[:reservations].split(',')) if cookies[:reservations].present?
    end

    def remove_cookie(id)
      cookies[:reservations] = (cookies[:reservations].split(',') - [id.to_s]).join(',')
    end

    def update_cookies
      cookies[:reservations] = reservations.ids.join(',') if cookies[:reservations].present?
    end

    def booking_status(reservation)
      return 'request_price' unless reservation.lodging_confirmed_price
      reservation.booking_status
    end
end
