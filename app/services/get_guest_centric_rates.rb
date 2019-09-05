class GetGuestCentricRates
  attr_reader :lodging
  attr_reader :uri
  attr_reader :params

  def self.call(lodging, params)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @lodging = lodging
    @params = params
    @uri = URI.parse("http://secure.guestcentric.net/api/secure/beapi/hotel/list_rates")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.set_form_data form_data
    response = JSON.parse http.request(request).body
  end

  private
    def header
      { 'username': ENV['GUEST_CENTRIC_USER'], 'pass': ENV['GUEST_CENTRIC_PASS'] }
    end

    def form_data
      {
        'HotelCode': lodging.guest_centric_id,
        'offer': params[:offer_id],
        'startDate': params[:check_in],
        "endDate": params[:check_out].to_date.prev_day,
        'nrAdults': params[:adults].to_i,
        'nrChildren': params[:children].to_i,
        'nrRooms': params[:rooms].to_i,
        'currency': 'EUR',
        'key': ENV['GUEST_CENTRIC_KEY'],
      }
    end
end
