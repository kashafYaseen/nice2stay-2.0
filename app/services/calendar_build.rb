class CalendarBuild
  attr_reader :lodging,
              :rules,
              :availabilities,
              :params,

  def self.call(lodging:, params:)
    new(lodging: lodging, params: params).call
  end

  def initialize(lodging:, params:)
    @lodging = lodging
    @params = params
    @rules = lodging.rules.active(check_in, check_out)
    @availabilities = lodging.availabilities.for_range(check_in, check_out)
  end

  def call
    response =  []
    availabilities.each do |availability|
      rule = rules.find { |rule| rule.start_date <= availability.available_on and rule.end_date >= availability.available_on }
      next unless rule.present?
      next if rule.minimum_stay.blank?

      lodging_params = params_based_on(availability, rule)
      price_details = lodging.price_details(lodging_params)
      next unless price_details[:valid]

      response << { date: availability.available_on, minlos: rule.minimum_stay.min, rate: price_details[:rates].sum.round(2) }
    end
    response.sort_by { |r| r[:date] }
  end

  private
    def check_in
      params[:check_in] || Date.today
    end

    def check_out
      params[:check_out] || Date.today.end_of_month
    end

    def params_based_on(availability, rule)
      [availability.available_on.to_s, (availability.available_on + rule.minimum_stay.min.day).to_s, params[:adults] || 1, params[:children], 1]
    end
end
