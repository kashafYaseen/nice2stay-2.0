class OpenGds::PaymentsRead
  attr_reader :reservation,
              :uri

  def self.call(reservation:)
    new(reservation: reservation).call
  end

  def initialize(reservation:)
    @reservation = reservation
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-reservation/payment-read?#{query_params}")
  end

  def call
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = JSON.parse(http.request(request).body)
    reservation.update(open_gds_deposit_amount: response['deposit'].to_f)
    response
  end

  private
    def query_params
      "#{credentials}&res_id=#{reservation.open_gds_res_id}&hash=#{reservation.open_gds_payment_hash}"
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end
end
