class SendReservationRemovalDetailsJob < ApplicationJob
  queue_as :default

  def perform(reservation_id, crm_booking_id, booking_id)
    SendReservationRemovalDetails.call(reservation_id, crm_booking_id, Booking.find_by(id: booking_id))
  end
end
