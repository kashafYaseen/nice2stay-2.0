class OpenGds::CalendarDeparture
  attr_reader :lodging,
              :params,
              :rate_plan,
              :uri,
              :default_adults

  def self.call(params:, lodging:, default_adults: nil)
    new(params: params, lodging: lodging, default_adults: default_adults).call
  end

  def initialize(params:, lodging:, default_adults:)
    @params = params
    @lodging = lodging
    @rate_plan = get_rate_plan
    @default_adults = default_adults
    @uri = URI.parse("https://api.opengds.com/core/v1/acc-status/calendar-depart?#{query_params}")
  end

  def call
    return if rate_plan.blank?

    result = []
    request = Net::HTTP::Get.new(uri.request_uri)
    request.content_type = 'application/x-www-form-urlencoded; charset=UTF-8'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = JSON.parse(http.request(request).body)
    if response.is_a?(Hash) # IF there will be hash in response it means there is an error occured in the request so we call the api with default adults 2
      return OpenGds::CalendarBuild.call(lodging: lodging, params: params, default_adults: 2)
    else
      return parse_data(response)
    end
  end

  private
    def parse_data(response)
      result = response.flatten.group_by{ |r| r["date"] }.reject{ |key, value| key.nil? }.map do |key, value|
        minimum_value = value.pluck("rate").reject(&:blank?).min
        value.find{ |val| val["rate"] == minimum_value }
      end

      result.reject{|r| r["rate"].blank?}
      result << { error: I18n.t('open_gds.error') } if default_adults
      result
    end

    def query_params
      "#{credentials}&#{calendar_params}"
    end

    def calendar_params
      "rate_id=#{rate_id}&accom_id=#{accommodation_id}&arrival=#{check_in}&occupancy=#{occupancy}"
    end

    def accommodation_id
      # total_occupancy = params[:adults].to_i + params[:children].to_i
      # rate_plan.room_rates.select{ |rr | rr.adults >= total_occupancy }.map(&:open_gds_accommodation_id).reject(&:blank?).sort.presence || rate_plan.room_ratesfirst.try(:open_gds_accommodation_id)
      rate_plan.room_rates.map{|rr| rr.child_lodging.try(:open_gds_accommodation_id)}.reject(&:blank?).sort
    end

    def rate_id
      rate_plan.open_gds_rate_id
    end

    def check_in
      params[:check_in] || Date.today
    end

    def occupancy
      adults = default_adults || params[:adults]
      "[#{adults}#{children}]"
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
      active_rate_plans = lodging.rate_plans.active
      active_rate_plans.find_by(id: params[:rate_plan_id]) || active_rate_plans.first
    end
end
