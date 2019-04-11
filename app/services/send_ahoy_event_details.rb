class SendAhoyEventDetails
  attr_reader :event
  attr_reader :uri

  def self.call(event)
    self.new(event).call
  end

  def initialize(event)
    @event = event
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/ahoy_events")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = event_details.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def event_details
      {
        ahoy_visit: event.visit,
        ahoy_event: event,
        customer: customer(event.user),
      }
    end

    def customer(user)
      return unless user.present?
      {
        email: user.email,
        name: user.first_name,
        surname: user.last_name,
        address: user.address,
        city: user.city,
        country_slug: user.country_slug,
        phone: user.phone,
        language: user.language,
      }
    end
end
