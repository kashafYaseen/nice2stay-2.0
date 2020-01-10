class SendLeadDetails
  attr_reader :lead
  attr_reader :uri

  def self.call(lead)
    self.new(lead).call
  end

  def initialize(lead)
    @lead = lead
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/leads")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = lead_details.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def lead_details
      {
        lead: {
          from: lead.check_in,
          to: lead.check_out,
          lead_type: 'favorite',
          adults: lead.adults,
          childrens: lead.children,
          notes: lead.notes,
          client_lead_id: lead.id,
          stay: lead.stay,
          budget: lead.budget,
          experience: lead.experience,
        },
        customer: customer(lead.user),
        accommodation_slug: lead.lodging_slug,
      }
    end

    def customer user
      {
        email: user.email,
        name: user.first_name,
        surname: user.last_name,
        address: user.address,
        city: user.city,
        country_slug: user.country_slug,
        phone: user.phone,
      }
    end
end
