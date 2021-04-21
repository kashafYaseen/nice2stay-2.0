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

    availabilities = room_rate.availabilities.where(available_on: dates)
    response = []
    availabilities.each do |availability|
      room_rate_params = params_based_on availability
      next if room_rate_params.blank?

      price_details = room_rate.price_details(room_rate_params)
      next unless price_details[:valid]

      response << { date: availability.available_on, rate: price_details[:rates].sum.round(2) / availability.min_stay, ctd: closed_to_departure?(availability) }
    end

    response << { date: dates[-1].to_date + 1.day, rate: nil, ctd: false } # checkout
    response.sort_by { |r| r[:date] }
  end

  private
    def params_based_on availability
      min_stay = availability.min_stay
      return if min_stay.blank?

      [availability.available_on.to_s, (availability.available_on + min_stay.to_i.days).to_s, params[:adults] || 1, params[:children], 1]
    end

    def dates
      (check_in_availability.available_on..check_in_availability.available_on + check_in_availability.max_stay.days).map(&:to_s)
    end

    def closed_to_departure? availability
      (availability.available_on - check_in_availability.available_on).to_i < check_in_availability.min_stay
    end
end
