class SendReservationDetails
  attr_reader :reservation
  attr_reader :uri

  def self.call(reservation)
    self.new(reservation).call
  end

  def initialize(reservation)
    @reservation = reservation
    @uri = URI.parse("http://localhost:3001/en/api/booking_carts")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = booking_cart.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def booking_cart
      {
        booking_cart: {
          accommodation_slug: reservation.lodging_slug,
          customer_email: reservation.user_email,
          from: reservation.check_in,
          to: reservation.check_out,
          persons: reservation.adults,
          childs: reservation.children,
          babies: reservation.infants,
          booking_total: reservation.total_price,
          rental_price: reservation.rent,
          discount: reservation.discount,
          cleaning_cost: reservation.cleaning_cost,
          skip_data_posting: true
        }
      }
    end
end
