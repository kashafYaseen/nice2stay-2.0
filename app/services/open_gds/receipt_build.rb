class OpenGds::ReceiptBuild
  attr_reader :reservation,
              :uri

  def self.call(reservation:)
    new(reservation: reservation).call
  end

  def initialize(reservation:)
    @reservation = reservation
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-status/receipt?#{credentials}")
  end

  def call
    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    request.set_form_data form_data
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = JSON.parse(http.request(request).body)
    reservation.update(open_gds_online_payment: true) if response['payment'].present?
    response
  end

  private
    def form_data
      {
        rate_id: reservation.open_gds_rate_id,
        accom_id: accommodation_ids,
        arrival: reservation.check_in,
        depart: reservation.check_out,
        occupancy: occupancy,
        first_name: reservation.user_first_name,
        last_name: reservation.user_last_name,
        phone: reservation.user_phone,
        email: reservation.user_email
      }
    end

    def accommodation_ids
      reservation.rooms.to_i.times.map { reservation.open_gds_accommodation_id }
    end

    def occupancy
      persons = ''
      reservation.rooms.to_i.times do |index|
        persons += adults_and_children
        persons += ',' if index < reservation.rooms.to_i - 1
      end

      persons
    end

    def adults_and_children
      "[#{reservation.adults}#{children}]"
    end

    def children
      return if reservation.children.zero?

      child_rate = reservation.child_rates.order(rate: :desc).first
      @child_category = child_rate&.open_gds_category || 1
      ", {\"#{@child_category}\": #{reservation.children}}"
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end
end
