class ReserveBookingExpertLodging
  attr_reader :lodging
  attr_reader :uri
  attr_reader :reservation
  attr_reader :user

  def self.call(lodging, reservation)
    self.new(lodging, reservation).call
  end

  def initialize(lodging, reservation)
    @lodging = lodging
    @reservation = reservation
    @user = reservation.user
    @uri = URI.parse("https://api.bookingexperts.nl/v1/administrations/#{lodging.be_admin_id}/reservations?include=rentable,invoice_items")
  end

  def call
    https = Net::HTTP.new(uri.host, uri.port);
    https.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = ENV['BOOKING_EXPERT_API_KEY']
    request["Accept"] = "application/vnd.api+json"
    request["Content-Type"] = "application/vnd.api+json"
    request.body = request_body

    response = JSON.parse https.request(request).body

    if response['errors']
      reservation.update_columns(channel_manager_errors: "#{response['errors'].to_json}", request_status: 'rejected')
    else
      reservation.update_columns(channel_manager_booking_id: response['data']['id'], booking_status: 'booked', request_status: 'confirmed')
    end
  end

  private
    def request_body
      {
        "data": {
          "type": "reservations",
          "attributes": {
            "start_date": reservation.check_in.to_s,
            "end_date": reservation.check_out.to_s,
            "guest_group": {
              "adults": reservation.adults.to_i,
              "children": reservation.children.to_i,
              "babies": reservation.infants.to_i
            },
            "currency": "EUR",
            "first_name": user.first_name,
            "last_name": user.last_name,
            "email": user.email,
            "phone": user.phone,
            "address": user.address,
            "city": user.city,
            "postalcode": user.zipcode,
            "country_code": user.country_code
          },
          "relationships": {
            "category": {
              "data": {
                "type": "categories",
                "id": lodging.be_category_id
              }
            }
          }
        }
      }.to_json
    end
end
