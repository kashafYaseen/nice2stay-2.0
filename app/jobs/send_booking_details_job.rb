class SendBookingDetailsJob < ApplicationJob
  queue_as :rr_prices_queue

  def perform(booking_id)
    SendBookingDetails.call(Booking.find_by(id: booking_id))
  end
end
