require 'csv'

class GetBookingExpertAvailabilities
  attr_reader :lodging
  attr_reader :uri
  attr_reader :params

  def self.call(lodging, params = nil)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @lodging = lodging
    @params = params

    if params.present?
      @uri = URI("https://api.bookingexperts.nl/v1/availabilities/search")
    else
      @uri = URI("https://api.bookingexperts.nl/v1/administrations/#{lodging.be_admin_id}/categories/#{lodging.be_category_id}/availabilities")
    end
  end

  def call
    https = Net::HTTP.new(uri.host, uri.port);
    https.use_ssl = true

    if params.present?
      #load child lodgings
      uri.query = URI.encode_www_form query_params
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = ENV['BOOKING_EXPERT_API_KEY']
      request["Accept-Language"] = "en"
      request["Accept"] = "application/vnd.api+json"

      response = JSON.parse https.request(request).body
    else
      #load only availabilites to populate calender
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = ENV['BOOKING_EXPERT_API_KEY']
      request["Accept-Language"] = "en"
      request['Accept'] = 'text/csv'

      response = parseCSV https.request(request).body
    end
  end

  private
    def query_params
      {
        'category_ids': lodging.lodging_children.pluck(:be_category_id).join(',').to_s,
        'filter[guest_group][adults]': params[:adults] || 1,
        'filter[guest_group][children]': params[:children].to_i,
        'filter[guest_group][babies]': params[:infants].to_i,
        'number_of_bedrooms': params[:rooms] || 1,
        'sorters[0][type]': 'arrangement_distance',
        'sorters[0][arrangement]': params[:check_in]..params[:check_out]
      }
    end

    def parseCSV response
      rows = CSV.parse(response)
      rows.shift
      rows = rows.map { |row| { start_date: row[0], los: row[1], rent_amount: row[2], discounted_rent_amount: row[3], discount_campaign_id: row[4], stock: row[5], available_for_pets: [6] } }
    end
end
