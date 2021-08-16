class SendReservationDetails
  attr_reader :reservation
  attr_reader :uri

  def self.call(reservation)
    self.new(reservation).call
  end

  def initialize(reservation)
    @reservation = reservation
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/bookings")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = booking.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def booking
      {
        booking: {
          accommodation_slug: reservation.lodging_slug,
          customer: customer(reservation.user),
          booking_accommodations_attributes: booking_accommodation,
          by_houseowner: false,
          created_by: 'customer',
          status: reservation.booking_status,
          skip_data_posting: true
        }
      }
    end

    def booking_accommodation
      [
        {
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
          booking_request_attributes: { status: 'new' }
        }
      ]
    end

    def customer(user)
      {
        email: user.email,
        name: user.first_name,
        surname: user.last_name,
        sign_in_count: user.sign_in_count,
      }
    end
end
