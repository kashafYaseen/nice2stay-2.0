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
    number_to_currency((price * multiplier), unit: '€', precision: ((price * multiplier).round == (price * multiplier)) ? 0 : round_by)
  end

  def pre_paid_link(booking)
    title_prefix = action_name == "show" ? "Pre Payment" : "£#{booking.pre_payment}"
    return link_to "#{title_prefix} Receiced: #{ render_date(booking.pre_payed_at) }", '#', class: "btn btn-success disabled w-100" if booking.step_passed?(:pre_paid)
    link_to "Pay #{title_prefix}", dashboard_booking_payment_path(booking, payment: 'pre-payment', locale: locale), class: "btn btn-info w-100", method: :post
  end

  def final_paid_link(booking)
    title_prefix = action_name == "show" ? "Final Payment" : "£#{booking.final_payment}"
    return link_to "#{title_prefix} Receiced: #{ render_date(booking.final_payed_at) }", '#', class: "btn btn-success disabled w-100" if booking.step_passed?(:fully_paid)
    link_to "Pay #{title_prefix}", dashboard_booking_payment_path(booking, payment: 'final-payment', locale: locale), class: "btn btn-info w-100", method: :post
  end
end
