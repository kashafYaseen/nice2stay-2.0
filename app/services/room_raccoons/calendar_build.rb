class RoomRaccoons::CalendarBuild
  attr_reader :room_rate,
              :params,
              :availabilities

  def self.call(room_rate:, params:)
    new(room_rate: room_rate, params: params).call
  end

  def initialize(room_rate:, params:)
    @room_rate = room_rate
    @params = params
    @availabilities = Availability.for_range(check_in, check_out).where(room_rate_id: room_rate.id)
  end

  def call
    response = []
    availabilities.each do |availability|
      room_rate_params = params_based_on availability
      next if room_rate_params.blank?

      price_details = room_rate.price_details(room_rate_params)
      next unless price_details[:valid]

      response << { date: availability.available_on.to_s, available: availability.rr_booking_limit, rate: price_details[:rates].sum.round(2), minlos: min_stay(availability), maxlos: max_stay(availability) }
    end

    response
  end

  private
    def check_in
      params[:check_in] || Date.today
    end

    def check_out
      params[:check_out] || Date.today.end_of_month
    end

    def params_based_on availability
      min_stay = min_stay(availability)
      return if min_stay.blank?

      [availability.available_on.to_s, (availability.available_on + min_stay.to_i.days).to_s, params[:adults] || 1, params[:children], 1]
    end

    def min_stay availability
      availability.rr_minimum_stay.min
    end

    def max_stay availability
      availability.rr_minimum_stay.max
    end
end
