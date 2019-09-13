class BookGuestCentricOffer
  attr_reader :lodging
  attr_reader :uri
  attr_reader :reservation
  attr_reader :booking
  attr_reader :user

  def self.call(lodging, reservation, booking)
    self.new(lodging, reservation, booking).call
  end

  def initialize(lodging, reservation, booking)
    @lodging = lodging
    @booking = booking
    @reservation = reservation
    @user = booking.user
    @uri = URI.parse("http://secure.guestcentric.net/api/secure/beapi/hotel/book")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.set_form_data form_data
    response = JSON.parse(http.request(request).body)
    reservation.update_columns(guest_centric_booking_id: response['response']['bookingCode'], booking_status: 'booked', request_status: 'confirmed') unless response['error']
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
        'firstName': user.first_name,
        'lastName': user.last_name,
        'email': user.email,
        'phone': user.phone,
        'address': user.address,
        'city': user.city,
        'zip_code': user.zipcode,
        'total': reservation.rent,
        'countryCode': user.country_code,
        'creditCardHolderName': user.first_name,
        'creditCardNumber': '4111111111111111',
        'creditCardMonth': '12',
        'creditCardYear': '2019',
        'creditCardType': 'Visa',
        'ccValidation': false
      }
    end
end
