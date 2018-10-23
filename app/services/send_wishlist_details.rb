class SendWishlistDetails
  attr_reader :wishlist
  attr_reader :uri

  def self.call(wishlist)
    self.new(wishlist).call
  end

  def initialize(wishlist)
    @wishlist = wishlist
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/favorites")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = wishlist_details.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def wishlist_details
      {
        lead: {
          from: wishlist.check_in,
          to: wishlist.check_out,
          lead_type: 'favorite',
          adults: wishlist.adults,
          childrens: wishlist.children,
          notes: wishlist.notes,
          client_wishlist_id: wishlist.id,
        },
        favorite: {
          name: wishlist.name,
          arrival_date: wishlist.check_in,
          daparture_date: wishlist.check_out,
          notes: wishlist.notes,
          number_adults: wishlist.adults,
          number_children: wishlist.children,
        },
        customer: customer(wishlist.user),
        accommodation_slug: wishlist.lodging_slug,
      }
    end

    def customer user
      {
        name: user.first_name,
        surname: user.last_name,
        email: user.email,
      }
    end
end
