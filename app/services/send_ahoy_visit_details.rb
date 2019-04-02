class SendAhoyVisitDetails
  attr_reader :visit
  attr_reader :uri

  def self.call(visit)
    self.new(visit).call
  end

  def initialize(visit)
    @visit = visit
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/ahoy_visits")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = visit_details.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def visit_details
      {
        ahoy_visit: visit,
        customer: customer(visit.user),
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
