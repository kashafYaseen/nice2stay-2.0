class SendReservationRemovalDetails
  attr_reader :booking
  attr_reader :reservation_id
  attr_reader :crm_booking_id
  attr_reader :uri

  def self.call(reservation_id, crm_booking_id, booking)
    self.new(reservation_id, crm_booking_id, booking).call
  end

  def initialize(reservation_id, crm_booking_id, booking)
    @booking = booking
    @reservation_id = reservation_id
    @crm_booking_id = crm_booking_id

    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/bookings/remove")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = booking_details.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def booking_details
      {
        uid: booking.uid,
        booking_accommodation_id: crm_booking_id,
        reservation_id: reservation_id,
      }
    end
end
