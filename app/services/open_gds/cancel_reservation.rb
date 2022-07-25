class OpenGds::CancelReservation
  attr_reader :reservation,
              :uri

  def self.call(reservation)
    new(reservation).call
  end

  def initialize(reservation)
    @reservation = reservation
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-reservation/cancel?#{credentials}")
  end

  def call
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    request.set_form_data form_data
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = JSON.parse(http.request(request).body)
    reservation.update(canceled_at_channel: DateTime.current) if response['success'].present?
  end

  private
    def form_data
      { res_id: reservation.open_gds_res_id }
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end
end
