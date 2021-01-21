class OpenGds::SearchPriceWithDates
  attr_reader :params,
              :room_rate

  def self.call(params, room_rate)
    new(params, room_rate).call
  end

  def initialize(params, room_rate)
    @params = params
    @room_rate = room_rate
  end

  def call
    search_price_with_defaults
  end

  private
    def search_price_with_defaults
      prices = SearchPrices.call(params.merge(children: 0)).uniq(&:available_on)
      price_list = prices.pluck(:amount)
      if room_rate.rate_type == 'ps'
        @adult_rate = adult_rate_by_single_rate_type
      end
      if room_rate.single_supplement? && params[:adult] == '1' && params[:children] == '0'
        @single_rate = prices.pluck(:open_gds_single_rate).sum
      elsif room_rate.single_rate? && params[:adult] == '1' && params[:children] == '0'
        price_list = prices.pluck(:open_gds_single_rate)
      end

      price = room_type.extra_night_rate.present? ? room_type.extra_night_rate : room_rate.default_rate
      price_list += [price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      price_list += [@single_rate] if @single_rate.present?
      price_list += get_daily_supplements
      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end

    def get_daily_supplements
      return 0 unless room_rate.open_gds_daily_supplements.present?

      daily_supplements = room_rate.open_gds_daily_supplements
      (check_out..check_in).map(&:to_date).inject(0) do |sum, date|
        sum + daily_supplements[date.strftime('%a')].to_f
      end
    end

    def calculate_child_rate adults_total
      return unless param[:children].present? || params[:children] == '0'

      if %w[pppn pp pppd pppn pp pppd papn ps papd].include?(room_rate.open_gds_rate_type)
        if params[:adult] == '1'
          return 0 if params[:children] == '1'

          child_rate = room_rate.child_rates_children.order(rate: :desc).first # get child rate with highest rate
          price_list.sum + (child_rate.rate * params[:minimum_stay] * (params[:children].to_i - 1))
        else
          child_rate = room_rate.child_rates_children.order(rate: :desc).first # get child rate with highest rate
          child_rate.rate * params[:minimum_stay] * params[:children].to_i
        end
      end
    end

    def extra_beds_used?
      return false if room_rate.extra_beds.zero?

      if room_rate.extra_beds_for_children_only
        params[:adults].to_i + params[:children].to_i >= room_rate.extra_beds + params[:max_adults].to_i
      else
        params[:adults].to_i > params[:max_adults].to_i
      end
    end

    def adult_rate_by_single_rate_type
      unless params[:adult] == '1' && params[:children] == '0'
        return ((room_rate.default_rate / room_rate.min_stay) + get_daily_supplements) * params[:total_nights]
      end

      if room_rate.single_supplement?
        return ((room_rate.default_rate / room_rate.min_stay) + get_daily_supplements) * params[:total_nights] + room_rate.default_single_rate
      end

      ((room_rate.default_single_rate / room_rate.min_stay) + get_daily_supplements) * params[:total_nights]
    end
end


# case room_rate.open_gds_rate_type
# when 'pppn' || 'pp' || 'pppd' && params[:adult] == '1'
#   return 0 if params[:children] == '1'
#
#   child_rate = room_rate.child_rates_children.order(rate: :desc).first # get child rate with highest rate
#   price_list.sum + (child_rate.rate * params[:minimum_stay] * (params[:children].to_i - 1))
# when 'pppn' || 'pp' || 'pppd' || 'papn' || 'pa' || 'papd' && (params[:adult].to_i > 1 || extra_beds_used?)
#   child_rate = room_rate.child_rates_children.order(rate: :desc).first # get child rate with highest rate
#   child_rate.rate * params[:minimum_stay] * params[:children].to_i
