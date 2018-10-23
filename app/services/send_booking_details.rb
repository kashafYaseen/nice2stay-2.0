class SendBookingDetails
  attr_reader :booking
  attr_reader :uri

  def self.call(booking)
    self.new(booking).call
  end

  def initialize(booking)
    @booking = booking
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/bookings")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = booking_details.to_json
    response = http.request(request)
    update_reservation_ids(response) if response.kind_of? Net::HTTPSuccess
    response
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def booking_details
      {
        booking: {
          customer: customer(booking.user),
          booking_accommodations_attributes: booking_accommodations,
          by_houseowner: false,
          created_by: 'customer',
          uid: booking.uid,
          created_at: booking.created_at,
          fe_identifier: booking.identifier,
          skip_data_posting: true,
        }
      }
    end

    def booking_accommodations
      reservations = []
      booking.reservations.order(:id).each do |reservation|
        reservations << {
          id: reservation.crm_booking_id,
          front_end_id: reservation.id,
          accommodation_slug: reservation.lodging_slug,
          from: reservation.check_in,
          to: reservation.check_out,
          persons_number: reservation.adults,
          children_number: reservation.children,
          babies: reservation.infants,
          total_price: reservation.total_price,
          rental_price: reservation.rent,
          discount: reservation.discount,
          cleaning_cost_price: reservation.cleaning_cost,
          status: reservation.booking_status,
          booking_status: reservation.booking_status,
          by_houseowner: false,
          skip_data_posting: true,
          booking_request_attributes: { status: request_status(reservation.request_status) }
        }
      end
      return reservations
    end

    def customer(user)
      {
        email: user.email,
        name: user.first_name,
        surname: user.last_name
      }
    end

    def request_status(status)
      return 'new' if status == 'pending'
      return 'accept' if status == 'confirmed'
      'reject'
    end

    def update_reservation_ids(response)
      crm_booking = JSON.parse response.body
      booking.reservations.order(:id).each_with_index { |r, i| r.update_column :crm_booking_id, crm_booking['booking_accommodation'][i]['id'] }
    end
end
