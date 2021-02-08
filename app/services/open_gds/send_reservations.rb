class OpenGds::SendReservations
  attr_reader :reservation,
              :uri

  def self.call(reservation:)
    new(reservation: reservation).call
  end

  def initialize(reservation:)
    @reservation = reservation
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-reservation/create?#{credentials}")
  end

  def call
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    request.set_form_data form_data
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = JSON.parse(http.request(request).body)
    if response['res_id'].present?
      reservation.update_attributes(open_gds_res_id: response['res_id'], request_status: 'confirmed', booking_status: 'booked')
    else
      reservation.update_attributes(
        open_gds_error_name: response['name'],
        open_gds_error_message: response['message'],
        open_gds_error_code: response['code'],
        open_gds_error_status: response['status'],
        request_status: 'rejected'
      )
    end
  end

  private
    def form_data
      {
        rate_id: reservation.open_gds_rate_id,
        accom_id: reservation.open_gds_accommodation_id,
        arrival: reservation.check_in,
        depart: reservation.check_out,
        occupancy: occupancy,
        first_name: reservation.user_first_name,
        last_name: reservation.user_last_name,
        phone: reservation.user_phone,
        email: reservation.user_email
      }
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end

    def occupancy
      "[#{reservation.adults}#{children}]"
    end

    def children
      return if reservation.children.zero? && reservation.infants.zero?

      result = ', {'
      if reservation.children.positive?
        child_rate = reservation.child_rates_children.order(rate: :desc).first
        @child_category = child_rate&.open_gds_category || 1
        result += "\"#{@child_category}\": #{reservation.children}"
      end

      if reservation.infants.positive?
        infant_rate = reservation.child_rates_infants.order(rate: :desc).first
        @infant_category = infant_rate&.open_gds_category || 2
        result += ',' if result.length > 1
        result += "\"#{@infant_category}\": #{reservation.infants}"
      end

      result += '}'
      result
    end
end
