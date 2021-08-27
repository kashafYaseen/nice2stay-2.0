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

    availabilities = lodging.availabilities.where(available_on: dates)
    response = []
    availabilities.each do |availability|
      lodging_params = params_based_on availability
      next if lodging_params.blank?

      price_details = lodging.price_details(lodging_params, false, true)
      next unless price_details[:valid]

      response << { date: availability.available_on, rate: price_details[:rates].sum.round(2), ctd: closed_to_departure?(availability) }
    end

    response << { date: dates[-1].to_date + 1.day, rate: nil, ctd: false } if response.present?
    response.sort_by { |r| r[:date] }
  end

  private
    def params_based_on availability
      min_stay = rule.min_stay
      return if min_stay.blank?

      [availability.available_on.to_s, (availability.available_on + min_stay.to_i.days).to_s, params[:adults] || 1, params[:children], false]
    end

    def dates
      (check_in_availability.available_on..check_in_availability.available_on + rule.max_stay.days - 1).map(&:to_s)
    end

    def closed_to_departure? availability
      !rule.minimum_stay.include? availability.available_on.mjd - params[:check_in].to_date.mjd
    end
end
