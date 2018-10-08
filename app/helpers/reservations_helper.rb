module ReservationsHelper
  def cart_items_count(reservations)
    return reservations.count if reservations.present?
    0
  end

  def cart_sub_total(reservations)
    return reservations.sum(:total_price) if reservations.present?
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
    (price * multiplier).round(round_by)
  end

  def pre_paid_link(status)
    text = status ? 'Pre Payment Receiced' : 'Pay Pre Payment'
    link_to text, '#', class: "btn #{status_button_class status} w-100"
  end

  def post_paid_link(status)
    text = status ? 'Final Payment Receiced' : 'Pay Final Payment'
    link_to text, '#', class: "btn #{status_button_class status} w-100"
  end

  def status_button_class status
    return 'btn-success disabled' if status
    'btn-info'
  end
end
