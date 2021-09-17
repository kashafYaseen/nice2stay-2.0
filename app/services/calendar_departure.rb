class CalendarDeparture
  attr_reader :lodging,
              :check_in_availability,
              :params,
              :rule

  def self.call(lodging:, params:)
    new(lodging: lodging, params: params).call
  end

  def initialize(lodging:, params:)
    @lodging = lodging
    @params = params
    @check_in_availability = lodging.availabilities.find_by(available_on: params[:check_in])
    @rule = lodging.rules_active(params[:check_in], params[:check_in]).first
  end

  def call
    return [] if check_in_availability.blank?

    prices = {}
    dates_combinations.each do |dates_combination|
      lodging_params = params_based_on dates_combination
      next if lodging_params.blank?
      price_details = lodging.price_details(values: lodging_params, flexible: false, daily_rate: true, calendar_departure: true)
      next unless price_details[:valid]

      price_details[:rates_with_dates].each do |rate_with_date|
        next if prices[rate_with_date[:date]].present?
        prices[rate_with_date[:date]] = { date: rate_with_date[:date], rate: rate_with_date[:rate], ctd: rate_with_date[:date] != dates_combination[:check_out].to_date }
      end
    end

    return [] if prices.blank?
    response = prices.keys.map { |res| prices[res] }.sort_by { |r| r[:date] }
    response[-1][:rate] = nil
    response
  end

  private
    def params_based_on dates_combination
      [dates_combination[:check_in].to_s, dates_combination[:check_out].to_s, params[:adults] || 1, params[:children], false]
    end

    def dates_combinations
      return [] unless rule.minimum_stay.present?
      rule.minimum_stay.map { |min_stay| { check_in: check_in_availability.available_on, check_out: check_in_availability.available_on + min_stay.to_i } }
    end
end
