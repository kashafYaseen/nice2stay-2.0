class CalendarBuild
  attr_reader :lodging, :params,

  def self.call(lodging:, params:)
    new(lodging: lodging, params: params).call
  end

  def initialize(lodging:, params:)
    @lodging = lodging
    @params = params
  end

  def call
    response =  []
    rules = lodging.rules_active(check_in, check_out)
    availabilities = lodging.availabilities.for_range(check_in, check_out)

    availabilities.each_with_index do |availability, index|
      rule = rules.find { |rule| rule.start_date <= availability.available_on and rule.end_date >= availability.available_on }
      next if rule.blank? || rule&.minimum_stay.blank?

      price_details = lodging.price_details(params_based_on(availability, rule), false)
      next unless price_details[:valid]

      response << { date: availability.available_on, minlos: rule.min_stay, rate: price_details[:rates].sum.round(2) }
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
      [availability.available_on.to_s, (availability.available_on + rule.minimum_stay.min.day).to_s, params[:adults] || 1, params[:children]]
    end
end
