class SendReservationDetailsJob < ApplicationJob
  queue_as :default

  def perform(reservation_id)
    SendReservationDetails.call(Reservation.find_by(id: reservation_id))
  end
end
