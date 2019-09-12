class BookGuestCentricOffer
  attr_reader :lodging
  attr_reader :uri
  attr_reader :reservation
  attr_reader :booking

  def self.call(lodging, reservation, booking)
    self.new(lodging, reservation, booking).call
  end

  def initialize(lodging, reservation, booking)
    @lodging = lodging
    @booking = booking
    @reservation = reservation
    @uri = URI.parse("http://secure.guestcentric.net/api/secure/beapi/hotel/book")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.set_form_data form_data
    JSON.parse http.request(request).body
  end

  private
    def header
      { 'username': ENV['GUEST_CENTRIC_USER'], 'pass': ENV['GUEST_CENTRIC_PASS'] }
    end

    def form_data
      {
        'HotelCode': lodging.guest_centric_id,
        "checkIn": reservation.check_in,
        "checkOut": reservation.check_out,
        'nrAdults': reservation.adults.to_i,
        'nrChildren': reservation.children.to_i,
        'childrenAges': '',
        'nrRooms': 1,
        'languageCode': 'nl',
        'currency': 'EUR',
        'key': ENV['GUEST_CENTRIC_KEY'],
        'offer': reservation.offer_id,
        'firstName': booking.user.first_name,
        'lastName': booking.user.last_name,
        'email': booking.user.email,
        'phone': booking.user.phone,
        'address': booking.user.address,
        'city': booking.user.city,
        'zip_code': booking.user.zipcode,
        'total': reservation.rent,
        'creditCardHolderName': booking.user.first_name,
        'creditCardNumber': '4111111111111111',
        'creditCardMonth': '12',
        'creditCardYear': '2019',
        'creditCardType': 'Visa',
        'countryCode': 'nl',
        'ccValidation': false
      }
    end
end
