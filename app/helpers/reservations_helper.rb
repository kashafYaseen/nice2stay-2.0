module ReservationsHelper
  def cart_items_count(reservations)
    return reservations.count if reservations.present?
    0
  end
end
