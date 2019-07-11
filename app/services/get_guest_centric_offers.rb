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
    @uri = URI.parse("http://secure.guestcentric.net/api/secure/beapi/hotel/find_offers?#{query_params}")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = param_details.to_json
    JSON.parse http.request(request).body
  end

  private
    def header
      { 'username': ENV['GUEST_CENTRIC_USER'], 'pass': ENV['GUEST_CENTRIC_PASS'] }
    end

    def param_details
      { }
    end

    def query_params
      "HotelCode=#{lodging.guest_centric_id}&checkIn=#{params[:check_in]}&nrNights=#{nights}&nrAdults=#{params[:adults].to_i}&nrChildren=#{params[:children].to_i}&nrRooms=#{params[:rooms].to_i}&languageCode=#{params[:locale]}&currency=EUR&key=#{ENV['GUEST_CENTRIC_KEY']}"
    end

    def nights
      return 1 unless params[:check_in].present? && params[:check_out].present?
      (params[:check_out].to_date - params[:check_in].to_date).to_i
    end
end
