class SearchPriceWithFlexibleDates
  attr_reader :params, :lodging, :room_rate
  include OpenGds::SearchPriceWithDates

  FLEXIBILITY = 3

  def self.call(params, lodging, room_rate = nil)
    self.new(params, lodging, room_rate).call
  end

  def initialize(params, lodging, room_rate = nil)
    @params = params
    @lodging = lodging
    @room_rate = room_rate
  end

  def call
    return calculate_daily_rates if params[:daily_rate].present? && params[:calendar_departure].present?
    if @lodging.present?
      return search_price_with_defaults unless lodging.as_child? && params[:flexible] && params[:flexible_type].blank?
      return flexible_search
    end

    search_price_for_room_rate
  end

  def flexible_search
    required_dates = (params[:check_in]..params[:check_out]).to_a.map(&:to_s)
    available_dates = available_days(params[:check_in], params[:check_out])
    unavailable_dates = required_dates - available_dates

    if unavailable_dates.count == 0 || unavailable_dates.count > FLEXIBILITY
      return search_price_with_defaults
    else
      diff = unavailable_dates.count
      results = []
      loop do
        if available_for?(required_dates[diff], required_dates[-1])
          results << search_price_with(params.merge(check_in: required_dates[diff], minimum_stay: minimum_stay(required_dates[diff], required_dates[-1])))
        end

        if available_for?(required_dates[0], required_dates[-diff])
          results << search_price_with(params.merge(check_out: required_dates[-diff], minimum_stay: minimum_stay(required_dates[0], required_dates[-diff])))
        end

        if diff == 2
          if available_for?(required_dates[1], required_dates[-2])
            results << search_price_with(params.merge(check_in: required_dates[1], check_out: required_dates[-2], minimum_stay: minimum_stay(required_dates[1], required_dates[-2])))
          end
        elsif diff == 3
          if available_for?(required_dates[1], required_dates[-3])
            results << search_price_with(params.merge(check_in: required_dates[1], check_out: required_dates[-3], minimum_stay: minimum_stay(required_dates[1], required_dates[-3])))
          end

          if available_for?(required_dates[2], required_dates[-2])
            results << search_price_with(params.merge(check_in: required_dates[2], check_out: required_dates[-2], minimum_stay: minimum_stay(required_dates[2], required_dates[-2])))
          end
        end

        break if diff >= FLEXIBILITY
        diff += 1
      end
    end
    return results if results.present?
    search_price_with_defaults
  end

  private
    def search_price_with_defaults
      lodging.flexible_search = false
      price_params = (params[:daily_rate] && params.merge(check_out: params[:check_in].to_date.next_day.to_s)) || params
      price_list = SearchPrices.call(price_params)
      return search_price_wrt_flexible_type(price_list) if params[:flexible].present? && params[:flexible_type].present?

      price_list = calculate_price_from(price_list, { check_in: params[:check_in], check_out: params[:check_out] })
      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors, check_in: params[:check_in], check_out: params[:check_out] }
    end

    def search_price_with(params)
      price_list = SearchPrices.call(params).uniq(&:available_on).pluck(:amount)
      price_list = price_list + [lodging.price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    # for Channel Managers price calculation
    def search_price_for_room_rate
      price_list =  if room_rate.room_raccoon?
                      price_params = (params[:daily_rate] && params.merge(check_out: params[:check_in].to_date.next_day.to_s)) || params
                      RoomRaccoons::SearchPrices.call(price_params.merge(adults: adults, extra_adults: extra_adults, children: extra_children))
                    else
                      price_params = (params[:daily_rate] && params.merge(check_out: params[:check_in].to_date.next_day.to_s)) || params.merge(check_out: check_out)
                      SearchPrices.call(price_params.merge(children: 0, channel: room_rate.channel))
                    end

      return search_price_wrt_flexible_type(price_list) if params[:flexible].present? && params[:flexible_type].present?
      price_list = calculate_price_from(price_list, { check_in: params[:check_in], check_out: params[:check_out] })
      reservation = build_reservation params
      { rates: price_list[:price], splited_rates_info: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors, check_in: params[:check_in], check_out: params[:check_out] }
    end

    def search_price_wrt_flexible_type price_list
      calculated_prices = []

      flexible_dates(prices_based_on_min_stay(price_list).map(&:available_on).min)&.each do |date_range|
        reservation = build_reservation params.merge(check_in: date_range[:check_in], check_out: date_range[:check_out])
        is_valid = reservation.validate
        next unless is_valid
        prices = calculate_price_from(price_list, date_range)
        return { rates: prices, search_params: params, valid: is_valid, errors: reservation.errors, check_in: date_range[:check_in], check_out: date_range[:check_out] }
      end

      { rates: [], search_params: params, valid: false, errors: "Not Valid!" }
    end

    def available_for?(check_in, check_out)
      return false unless check_in.present? && check_out.present? && minimum_stay(check_in, check_out) > 1
      required_dates = (check_in..check_out).to_a.map(&:to_s)
      availabilities = lodging.availabilities.for_range(check_in, check_out)
      return false unless availabilities.check_out_only.pluck(:available_on).map(&:to_s) == [check_out] || availabilities.check_out_only.pluck(:available_on).map(&:to_s).blank?
      available_dates = availabilities.pluck(:available_on).map(&:to_s)
      return false unless (required_dates - available_dates).count == 0
      lodging.flexible_search = true
    end

    def minimum_stay(check_in = nil, check_out = nil)
      return (check_out.to_date - check_in.to_date).to_i if check_in.present? && check_out.present?
      return params[:minimum_stay] unless params[:daily_rate]
      1
    end

    def checkin_day
      check_in = params[:check_in].presence || params[:check_out]
      Date.parse(check_in).strftime("%A").downcase
    end

    def available_days(check_in, check_out)
      availabilities = lodging.availabilities.for_range(params[:check_in], params[:check_out])
      all = availabilities.pluck(:available_on).map(&:to_s)
      check_out_only = availabilities.check_out_only.pluck(:available_on).map(&:to_s)
      all - (check_out_only - [check_out])
    end

    def extra_adults
      extra_adults = params[:max_adults].to_i - params[:adults].to_i
      extra_adults.negative? ? extra_adults.abs : 0
    end

    def extra_children
      remaining_adults = params[:max_adults].to_i - params[:adults].to_i
      children = remaining_adults - params[:children].to_i
      children = children.negative? ? children.abs : 0
      children -= remaining_adults.abs if remaining_adults.negative?
      children
    end

    def adults
      params[:adults].to_i - extra_adults
    end

    def build_reservation(params)
      return Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: lodging, booking: Booking.new) if lodging.present?
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end

    def additional_adults_prices prices
      prices.select { |price| price.rr_additional_amount_flag && price.adults == ["1"] && price.children == ["0"] }
    end

    def additional_children_prices prices
      prices.select { |price| price.rr_additional_amount_flag && price.adults == ["0"] && price.children == ["1"] }
    end

    def reservation_dates
      (params[:check_in].to_date..(params[:check_out].to_date - 1.day)).to_a.map(&:to_s)
    end

    def calculate_price_from price_list, date_range
      prices = (params[:flexible].present? && params[:flexible_type].present? && price_list.select { |price| price.available_on >= date_range[:check_in].to_date && price.available_on < date_range[:check_out].to_date }) || price_list

      if room_rate.present? && room_rate.room_raccoon?
        price_list_without_additional_price = prices.reject(&:rr_additional_amount_flag).uniq(&:available_on).pluck(:amount)
        price_list_without_additional_price += [room_rate.default_rate.to_f] * (minimum_stay - price_list_without_additional_price.size) if price_list_without_additional_price.size < minimum_stay

        additional_adults_prices_list = additional_adults_prices(prices).uniq(&:available_on).pluck(:amount)
        additional_adults_prices_list += [(price_list_without_additional_price.sum / minimum_stay.to_i).to_f] * (minimum_stay - additional_adults_prices_list.size) if additional_adults_prices_list.size < minimum_stay

        additional_children_prices_list = additional_children_prices(prices).uniq(&:available_on).pluck(:amount)
        additional_children_prices_list += [(price_list_without_additional_price.sum / minimum_stay.to_i).to_f] * (minimum_stay - additional_children_prices_list.size) if additional_children_prices_list.size < minimum_stay

        prices = price_list_without_additional_price + (additional_adults_prices_list * extra_adults) + (additional_children_prices_list * extra_children)
      elsif room_rate.present? && room_rate.open_gds?
        prices = prices.uniq(&:available_on)
        prices = calculate_adult_rates(prices)
        children_rates = calculate_children_rates(prices[:price])
        prices[:price] += children_rates.try(:[], :children_rates)
        prices[:children_rates] = children_rates.try(:[], :children_rates).sum.round(2) * (params[:rooms] || 1).to_i
        prices[:num_of_children_with_extrabeds] = children_rates.try(:[], :num_of_children_with_extrabeds)
      else
        prices = prices.uniq(&:available_on).pluck(:amount)
        prices = prices + [lodging.price.to_f] * (minimum_stay - prices.size) if prices.size < minimum_stay
      end

      prices
    end

    def calculate_daily_rates
      price_list =  if lodging.present?
                      SearchPrices.call(params.merge(check_out: (params[:check_out].to_date + 1.day).to_s)).uniq(&:available_on)
                    else
                      RoomRaccoons::SearchPrices.call(params.merge(adults: adults, extra_adults: extra_adults, children: extra_children, check_out: (params[:check_out].to_date + 1.day).to_s))
                    end

      prices = []
      price_list.each do |price|
        prices << { date: price.available_on, rate: calculate_price_from([price], { check_in: price.available_on, check_out: price.available_on + 1.day }).sum.round(2) }
      end

      reservation = build_reservation params
      { rates_with_dates: prices, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def prices_based_on_min_stay(price_list)
      return price_list if lodging.present?
      price_list.select do |price|
        (params[:flexible_type] == 'week' && price.availability_max_stay >= 7) ||
          (params[:flexible_type] == 'weekend' && price.availability_max_stay >= 2) ||
          (params[:flexible_type] == 'long_weekend' && price.availability_max_stay >= 3)
      end
    end

    def flexible_dates(min_available_on)
      return [] unless min_available_on.present?
      params[:flexible_dates].select { |dates| dates[:check_out].to_date >= min_available_on }
    end
end
