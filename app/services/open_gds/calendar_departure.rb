class OpenGds::CalendarDeparture
  attr_reader :lodging,
              :params,
              :rate_plan,
              :accommodation_id,
              :uri

  def self.call(lodging:, params:, accommodation_id:)
    new(lodging: lodging, params: params, accommodation_id: accommodation_id).call
  end

  def initialize(lodging:, params:, accommodation_id:)
    @params = params
    @lodging = lodging
    @rate_plan = get_rate_plan
    @accommodation_id = accommodation_id
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-status/calendar-depart?#{query_params}")
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
      "rate_id=#{rate_id}&accom_id=#{accommodation_id}&arrival=#{check_in}&occupancy=#{occupancy}"
    end

    # def accommodation_id
    #   lodging.lodging_children.pluck(:open_gds_accommodation_id)
    # end

    def rate_id
      rate_plan.open_gds_rate_id
    end

    def check_in
      params[:check_in] || Date.today
    end

    def occupancy
      "[#{params[:adults]}#{children}]"
    end

    def children
      return unless params[:children].present?

      child_rate = rate_plan.child_rates.order(rate: :desc).first
      child_category = child_rate&.open_gds_category || 1
      ", {\"#{child_category}\": #{params[:children]}}"
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end

    def get_rate_plan
      lodging.rate_plans.active.find_by(id: params[:rate_plan_id]) || lodging.rate_plans.active.first
    end
end
