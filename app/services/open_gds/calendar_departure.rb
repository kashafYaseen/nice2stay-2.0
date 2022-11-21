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

  def fetch
    room_rate_ids = rate_plan.room_rate_ids
    check_in_availabilities = Availability.where(room_rate_id: room_rate_ids, available_on: params[:check_in])
    response = []
    check_in_availabilities.each do |check_in_availability|
      prices = {}
      dates_combinations(check_in_availability).each do |dates_combination|
        room_rate_params = params_based_on dates_combination
        next if room_rate_params.blank?

        price_details = check_in_availability.room_rate.price_details(values: room_rate_params, daily_rate: true, calendar_departure: true)
        next unless price_details[:valid]

        price_details[:rates_with_dates].each do |rate_with_date|
          next if prices[rate_with_date[:date]].present?
          prices[rate_with_date[:date]] = { date: rate_with_date[:date], rate: rate_with_date[:rate], ctd: rate_with_date[:date] != dates_combination[:check_out].to_date }
        end

        prices[dates_combination[:check_out].to_date] = { date: dates_combination[:check_out].to_date, rate: nil, ctd: false } unless prices[dates_combination[:check_out].to_date].present?

      end

      next if prices.blank?
      response << prices.keys.map { |res| prices[res] }.sort_by { |r| r[:date] }
    end

    response = response.flatten.group_by{|r| r[:date]}.map{|key, value| value.find{|val| val[:rate] == value.pluck(:rate).min}}
    response[-1][:rate] = nil
    response
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
      lodging.rate_plans.find_by(id: params[:rate_plan_id]) || lodging.rate_plans.first
    end
end
