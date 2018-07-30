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

  private
    def set_reservations
      return @reservations = user.reservations_in_cart if user.present?
      @reservations = Reservation.where(id: cookies[:reservations].split(',')) if cookies[:reservations].present?
    end

    def update_cookies
      cookies[:reservations] = reservations.ids.join(',') if cookies[:reservations].present?
    end
end
