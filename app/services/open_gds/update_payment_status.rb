class OpenGds::UpdatePaymentStatus
  attr_reader :reservation,
              :uri,
              :payment_status

  def self.call(reservation:, payment_status: 'pending')
    new(reservation: reservation, payment_status: payment_status).call
  end

  def initialize(reservation:, payment_status: 'pending')
    @reservation = reservation
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-reservation/payment-update?#{credentials}")
    @payment_status = payment_status
  end

  def call
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    request.set_form_data form_data
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = JSON.parse(http.request(request).body)
    reservation.update_columns(open_gds_payment_status: payment_status, booking_status: 'booked') if response['success']
    response
  end

  private
    def form_data
      {
        res_id: reservation.open_gds_res_id,
        hash: reservation.open_gds_payment_hash,
        payment_status: payment_status
      }
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end
end
