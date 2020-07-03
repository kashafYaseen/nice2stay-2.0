require 'csv'

class GetBookingExpertAvailabilities
  attr_reader :lodging
  attr_reader :uri

  def self.call(lodging)
    self.new(lodging).call
  end

  def initialize(lodging)
    @lodging = lodging
    @uri = URI.parse("https://api.bookingexperts.nl/v1/administrations/#{lodging.be_admin_id}/categories/#{lodging.be_category_id}/availabilities")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    # #headers
    request['Authorization'] = ENV['BOOKING_EXPERT_API_KEY']
    request['Accept'] = 'text/csv'

    response = parseCSV http.request(request).body
  end

  private
    def parseCSV response
      rows = CSV.parse(response)
      rows.shift
      rows = rows.map { |row| { start_date: row[0], los: row[1], rent_amount: row[2], discounted_rent_amount: row[3], discount_campaign_id: row[4], stock: row[5], available_for_pets: [6] } }
    end
end
