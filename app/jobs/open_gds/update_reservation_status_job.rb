class OpenGds::UpdateReservationStatusJob < ApplicationJob
  queue_as :default

  def perform(reservation_id)
    reservation = Reservation.find_by(id: reservation_id)
    reservation.update(open_gds_payment_status: :expired, request_status: :expired, in_cart: false) if reservation.present? && reservation.open_gds? && reservation.open_gds_res_id.present? && reservation.open_gds_online_payment?
  end
end
