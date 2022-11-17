class OpenGds::CalendarBuild
  attr_reader :rate_plan,
              :params,
              :lodging,
              :uri

  def self.call(params:, lodging:)
    new(params: params, lodging: lodging).call
  end

  def initialize(params:, lodging:)
    @params = params
    @lodging = lodging
    @rate_plan = get_rate_plan
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-status/calendar?#{query_params}")
  end

  def call
    return if rate_plan.blank?

    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    parse_data(JSON.parse(http.request(request).body))
  end

  def parse_data(response)
    return [] if response.blank?

    response.group_by{|r| r["date"]}.map{|key, value| value.find{|val| val["rate"] == value.pluck("rate").min}}
  end

  private
    def query_params
      "#{credentials}&#{calendar_params}"
    end

    def calendar_params
      "rate_id=#{rate_id}&accom_id=#{accommodation_id}&from=#{check_in}&till=#{check_out}&occupancy=#{occupancy}"
    end

    def accommodation_id
      lodging.lodging_children.pluck(:open_gds_accommodation_id).sort
    end

    def rate_id
      rate_plan.open_gds_rate_id
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

      child_rate = rate_plan.child_rates.order(rate: :desc).first
      child_category = child_rate&.open_gds_category || 1
      ", {\"#{child_category}\": #{params[:children]}}"
    end

    def credentials
      "privkey=#{ENV['OPENGDS_PRIV_KEY']}&apikey=#{ENV['OPENGDS_API_KEY']}"
    end

    def get_rate_plan
      lodging.rate_plans.find_by(id: params[:rate_plan_id]) || lodging.rate_plans.first
    end
end
