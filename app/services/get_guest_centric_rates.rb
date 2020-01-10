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
      { 'username': lodging.gc_username, 'pass': lodging.gc_password }
    end

    def form_data
      {
        'HotelCode': lodging.guest_centric_id,
        'offer': params[:offer_id],
        'startDate': Date.current.to_s,
        "endDate": 1.year.from_now.to_date.to_s,
        'nrAdults': params[:adults].presence || 1,
        'nrChildren': params[:children],
        'nrRooms': params[:rooms].presence || 1,
        'currency': 'EUR',
        'key': ENV['GUEST_CENTRIC_KEY'],
      }
    end
end
