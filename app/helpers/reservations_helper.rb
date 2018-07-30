module ReservationsHelper
  def cart_items_count(reservations)
    return reservations.count if reservations.present?
    0
  end

  def cart_sub_total(reservations)
    return "$#{reservations.sum(:total_price)}" if reservations.present?
    "$0"
  end
end
