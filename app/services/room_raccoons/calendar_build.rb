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
    @availabilities = room_rate.availabilities.for_range(check_in, check_out)
  end

  def call
    response = []
    availabilities.each do |availability|
      room_rate_params = params_based_on availability
      next if room_rate_params.blank?

      price_details = room_rate.price_details(room_rate_params)
      next unless price_details[:valid]

      response << { date: availability.available_on.to_s, available: availability.rr_booking_limit, rate: price_details[:rates].sum.round(2), minlos: availability.min_stay, maxlos: availability.max_stay }
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
      min_stay = availability.min_stay
      return if min_stay.blank?

      [availability.available_on.to_s, (availability.available_on + min_stay.to_i.days).to_s, params[:adults] || 1, params[:children], 1]
    end
end
