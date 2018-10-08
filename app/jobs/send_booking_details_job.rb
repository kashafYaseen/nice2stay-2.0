class SendBookingDetailsJob < ApplicationJob
  queue_as :default

  def perform(booking_id)
    SendBookingDetails.call(Booking.find_by(id: booking_id))
  end
end
