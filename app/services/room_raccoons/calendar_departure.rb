class RoomRaccoons::CalendarDeparture
  attr_reader :room_rate,
              :check_in_availability,
              :params

  def self.call(room_rate:, params:)
    new(room_rate: room_rate, params: params).call
  end

  def initialize(room_rate:, params:)
    @room_rate = room_rate
    @params = params
    @check_in_availability = room_rate.availabilities.find_by(available_on: params[:check_in])
  end

  def call
    return [] if check_in_availability.blank?

    prices = {}
    dates_combinations.each do |dates_combination|
      room_rate_params = params_based_on dates_combination
      next if room_rate_params.blank?

      price_details = room_rate.price_details(values: room_rate_params, daily_rate: true, calendar_departure: true)
      next unless price_details[:valid]

      price_details[:rates_with_dates].each do |rate_with_date|
        next if prices[rate_with_date[:date]].present?
        prices[rate_with_date[:date]] = { date: rate_with_date[:date], rate: rate_with_date[:rate], ctd: rate_with_date[:date] != dates_combination[:check_out].to_date }
      end

      prices[dates_combination[:check_out].to_date] = { date: dates_combination[:check_out].to_date, rate: nil, ctd: false } unless prices[dates_combination[:check_out].to_date].present?
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
      return [] unless check_in_availability.minimum_stay.present?
      check_in_availability.minimum_stay.map { |min_stay| { check_in: check_in_availability.available_on, check_out: check_in_availability.available_on + min_stay.to_i } }
    end
end
