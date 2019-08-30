class BookGuestCentricOffer
  attr_reader :lodging
  attr_reader :uri
  attr_reader :params

  def self.call(lodging, params)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @lodging = lodging
    @params = params
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
        "checkIn": params[:check_in],
        "checkOut": params[:check_out],
        'nrAdults': params[:adults].to_i,
        'nrChildren': params[:children].to_i,
        'childrenAges': params[:children_ages],
        'nrRooms': params[:rooms].to_i,
        'languageCode': params[:locale],
        'currency': 'EUR',
        'key': ENV['GUEST_CENTRIC_KEY'],
        'offer': params[:offer_id],
        'firstName': params[:first_name],
        'lastName': params[:last_name],
        'email': params[:email],
        'phone': params[:phone],
        'address': params[:address],
        'city':, params[:city],
        'zip_code': params[:zip_code],
        'total': params[:total],
        'creditCardHolderName': ,
        'creditCardNumber': '4111111111111111',
        'creditCardMonth': '12',
        'creditCardYear': '2019',
        'creditCardType': 'Visa',
        'countryCode': params[:country_code],
      }
    end
end




