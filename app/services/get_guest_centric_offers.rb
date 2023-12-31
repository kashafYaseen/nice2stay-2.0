class GetGuestCentricOffers
  attr_reader :lodging
  attr_reader :uri
  attr_reader :params

  def self.call(lodging, params)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @lodging = lodging
    @params = params
    @uri = URI.parse("http://secure.guestcentric.net/api/secure/beapi/hotel/find_offers")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.set_form_data form_data
    JSON.parse http.request(request).body
  end

  private
    def header
      { 'username': lodging.gc_username, 'pass': lodging.gc_password }
    end

    def form_data
      {
        'HotelCode': lodging.guest_centric_id,
        "checkIn": params[:check_in],
        'nrNights': nights,
        'nrAdults': params[:adults] || 1,
        'nrChildren': params[:children].to_i,
        'nrRooms': params[:rooms] || 1,
        'languageCode': 'en',
        'currency': 'EUR',
        'key': ENV['GUEST_CENTRIC_KEY'],
        'includeCancelPolicies': 1,
      }
    end

    def nights
      return 1 unless params[:check_in].present? && params[:check_out].present?
      (params[:check_out].to_date - params[:check_in].to_date).to_i
    end
end
