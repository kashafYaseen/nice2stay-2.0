module ReservationsHelper
  def cart_items_count(reservations)
    return reservations.count if reservations.present?
    0
  end

  def cart_sub_total(reservations)
    return reservations.sum(:rent) if reservations.present?
    0
  end

  def show_password_fields?(user)
    return true if user.with_login?
    false
  end

  def render_reservation_dates(reservation)
    "#{reservation.check_in} - #{reservation.check_out}"
  end

  def render_reservation_guests(reservation)
    guests = "Adults: #{reservation.adults.to_i}"
    guests += "- Children: #{reservation.children}" if reservation.children.to_i > 0
    guests
  end

  def render_request_status(status)
    status_classes = ['bg-warning', 'bg-success', 'bg-danger']
    "<span class='d-inline-block #{status_classes[Reservation.request_statuses[status]]} text-white text-xs p-1'>#{status.humanize}</span>".html_safe
  end

  def render_reservation_type(type)
    return "<span class='d-inline-block text-xs p-1 text-secondary'>Option</span>".html_safe if type == 'option'
    "<span class='d-inline-block text-xs p-1 text-primary'>Booking</span>".html_safe
  end

  def render_rounded_price(price, multiplier = 1, round_by = 2)
    return '--' unless price.present?
    number_to_currency((price * multiplier), unit: '€', separator: ',', delimiter: "", precision: ((price * multiplier).round == (price * multiplier)) ? 0 : round_by)
  end

  def reservation_badge_class(reservation)
    return 'badge-warning' if reservation.pending?
    return 'badge-success' if reservation.confirmed?
    'badge-info'
  end

  def render_meal_title(meal_id)
    return 'Bed & Breakfast' if meal_id.to_i == 2
    return 'Half-Board' if meal_id.to_i == 3
    return 'Full-Board' if meal_id.to_i == 4
    return 'All Inclusive' if meal_id.to_i == 5
    'Meals'
  end

  def render_meal_price(per_day_price, params)
    return per_day_price unless get_centric_param(:check_in).present? && get_centric_param(:check_out).present?
    (per_day_price.to_f * (get_centric_param(:check_out).to_date - get_centric_param(:check_in).to_date).to_i).round(2)
  end

  def pre_paid_link(booking)
    title_prefix = action_name == "show" ? "Pre Payment" : "€#{booking.pre_payment}"
    return link_to "#{title_prefix} Receiced: #{ render_date(booking.pre_payed_at) }", '#', class: "btn btn-success disabled w-100" if booking.step_passed?(:pre_paid)
    link_to "Pay #{title_prefix}", dashboard_booking_payment_path(booking, payment: 'pre-payment', locale: locale), class: "btn btn-info w-100", method: :post
  end

  def final_paid_link(booking)
    title_prefix = action_name == "show" ? "Final Payment" : "€#{booking.final_payment}"
    return link_to "#{title_prefix} Receiced: #{ render_date(booking.final_payed_at) }", '#', class: "btn btn-success disabled w-100" if booking.step_passed?(:fully_paid)
    link_to "Pay #{title_prefix}", dashboard_booking_payment_path(booking, payment: 'final-payment', locale: locale), class: "btn btn-info w-100 #{ 'disabled' unless booking.step_passed?(:pre_paid) }", method: :post
  end
end
