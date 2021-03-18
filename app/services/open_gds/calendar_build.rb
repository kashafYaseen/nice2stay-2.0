class OpenGds::CalendarBuild
  attr_reader :room_rate,
              :params,
              :uri

  def self.call(room_rate:, params:)
    new(room_rate: room_rate, params: params).call
  end

  def initialize(room_rate:, params:)
    @room_rate = room_rate
    @params = params
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-status/calendar?#{query_params}")
  end

  def call
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    JSON.parse(http.request(request).body)
  end

  private
    def query_params
      "#{credentials}&#{calendar_params}"
    end

    def calendar_params
      "rate_id=#{rate_id}&accom_id=#{accommodation_id}&from=#{check_in}&till=#{check_out}&occupancy=#{occupancy}"
    end

    def accommodation_id
      room_rate.open_gds_accommodation_id
    end

    def rate_id
      room_rate.open_gds_rate_id
    end

    def check_in
      params[:check_in] || Date.today
    end

    def check_out
      params[:check_out] || Date.today.end_of_month
    end

    def occupancy
      "[#{params[:adults]}#{children}]"
    end

    def children
      return unless params[:children].present?

      child_rate = room_rate.child_rates.order(rate: :desc).first
      @child_category = child_rate&.open_gds_category || 1
      ", {\"#{@child_category}\": #{params[:children]}}"
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end
end
