module ReservationsHelper
  def cart_items_count(reservations)
    return reservations.count if reservations.present?
    0
  end

  def cart_sub_total(reservations)
    return "$#{reservations.sum(:total_price)}" if reservations.present?
    "$0"
  end

  def show_password_fields?(user)
    return true if user.with_login?
    false
  end

  def render_reservation_dates(reservation)
    "#{reservation.check_in} - #{reservation.check_out}"
  end
end
