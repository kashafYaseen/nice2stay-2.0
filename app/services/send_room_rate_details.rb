class SendRoomRateDetails
  attr_reader :room_rate, :uri

  def self.call(room_rate)
    new(room_rate).call
  end

  def initialize(room_rate)
    @room_rate = room_rate
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/room_rates")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    # http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = room_rate_body.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def room_rate_body
      {
        room_rate: {
          child_accommodation_id: room_rate.child_lodging_crm_id,
          rate_plan_id:room_rate.rate_plan_crm_id
        }
      }
    end
end
