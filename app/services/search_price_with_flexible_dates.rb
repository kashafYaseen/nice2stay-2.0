class SearchPriceWithFlexibleDates
  attr_accessor :params
  attr_reader :lodging
  attr_reader :room_rate

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
      self.params = (params[:flexible].present? && params[:flexible_type].present? && minimum_stay_wrt_flexible_type) || params
      price_list = SearchPrices.call(params)
      return search_price_wrt_flexible_type(price_list) if params[:flexible].present? && params[:flexible_type].present?
      price_list = price_list.uniq(&:available_on).pluck(:amount)
      price_list = price_list + [lodging.price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      reservation = build_reservation params
      return { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def search_price_with(params)
      price_list = SearchPrices.call(params).uniq(&:available_on).pluck(:amount)
      price_list = price_list + [lodging.price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      reservation = build_reservation params
      return { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def search_price_for_room_rate
      price_list = RoomRaccoons::SearchPrices.call(params.merge(adults: adults, extra_adults: extra_adults, children: extra_children))
      price_list_without_additional_price = price_list.reject(&:rr_additional_amount_flag).uniq(&:available_on).pluck(:amount)
      price_list_without_additional_price += [room_rate.default_rate.to_f] * (params[:minimum_stay] - price_list_without_additional_price.size) if price_list_without_additional_price.size < params[:minimum_stay]

      additional_adults_prices_list = additional_adults_prices(price_list).uniq(&:available_on).pluck(:amount)
      additional_adults_prices_list += [(price_list_without_additional_price.sum / params[:minimum_stay].to_i).to_f] * (params[:minimum_stay] - additional_adults_prices_list.size) if additional_adults_prices_list.size < params[:minimum_stay]

      additional_children_prices_list = additional_children_prices(price_list).uniq(&:available_on).pluck(:amount)
      additional_children_prices_list += [(price_list_without_additional_price.sum / params[:minimum_stay].to_i).to_f] * (params[:minimum_stay] - additional_children_prices_list.size) if additional_children_prices_list.size < params[:minimum_stay]

      price_list = price_list_without_additional_price + (additional_adults_prices_list * extra_adults) + (additional_children_prices_list * extra_children)
      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def search_price_wrt_flexible_type price_list
      calculated_prices = []
      flexible_dates.each do |date_range|
        prices = price_list.select { |price| price.available_on >= date_range[:check_in] && price.available_on <= date_range[:check_out] }
        prices = prices.uniq(&:available_on).pluck(:amount)
        prices = prices + [lodging.price.to_f] * (params[:minimum_stay] - prices.size) if prices.size < params[:minimum_stay]
        reservation = build_reservation params.merge(check_in: date_range[:check_in], check_out: date_range[:check_out])
        is_valid = reservation.validate
        return { rates: prices, search_params: params, valid: is_valid, errors: reservation.errors } if is_valid
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

    def minimum_stay(check_in, check_out)
      (check_out.to_date - check_in.to_date).to_i
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

    def calculate_price_from price_list
      reservation_dates.each do |reservation_date|
        applied_amount = 0
        prices_per_day = applied_prices.select { |applied_price| applied_price.available_on.to_s == reservation_date }

        if reservation_date == params[:check_in]
          prices_per_day.each do |ppd|
            applied_amount = ppd.amount if ppd.has_adults?(params[:adults]) && ppd.has_children?(params[:children]) && ppd.has_minimum_stay?(params[:minimum_stay]) && [checkin_day, 'any'].include?(ppd.checkin)
            break if applied_amount.present?
          end
          price_list << applied_amount if applied_amount > 0
        else
          applied_amount = prices_per_day.map(&:amount).min
          price_list << applied_amount if applied_amount.to_i > 0
        end
      end
      price_list = price_list.map(&:to_f)

      price_list = price_list + [lodging.price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def flexible_dates
      dates = []
      if params[:flexible_type] == 'week'
        checkin = params[:check_in].to_date
        checkout = checkin + 7.days
        (params[:check_in].to_date..(params[:check_out].to_date - 7.days)).map(&:to_date).size.times do |index|
          dates << { check_in: checkin, check_out: checkout }
          checkin += 1.day
          checkout += 1.day
        end
      end

      dates
    end

    def minimum_stay_wrt_flexible_type
      return params.merge(minimum_stay: 7) if params[:flexible_type] == 'week'
    end
end
