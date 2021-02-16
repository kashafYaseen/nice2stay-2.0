class SearchPriceWithFlexibleDates
  attr_reader :params
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
      return search_price_with_defaults unless lodging.as_child? && params[:flexible]
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
      price_list = SearchPrices.call(params).uniq(&:available_on).pluck(:amount)
      price = lodging.price
      lodging.flexible_search = false
      price_list = price_list + [price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
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
      price_list = RoomRaccoons::SearchPrices.call(params.merge(adults: adults, extra_adults: extra_adults))
      price_list_without_additional_price = price_list.reject(&:rr_additional_amount_flag).uniq(&:available_on).pluck(:amount)
      price_list_without_additional_price += [room_rate.default_rate.to_f] * (params[:minimum_stay] - price_list_without_additional_price.size) if price_list_without_additional_price.size < params[:minimum_stay]
      price_list_with_additional_price = price_list.select(&:rr_additional_amount_flag)
      price_list_with_additional_price.each do |price|
        price.amount *= extra_adults if price.adults.sum.to_i.positive?
        price.amount *= params[:children].to_i if price.children.sum.to_i.positive?
      end

      price_list_with_additional_price = price_list_with_additional_price.pluck(:amount)
      price_list = price_list_without_additional_price + price_list_with_additional_price

      reservation = build_reservation params
      { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
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

    def adults
      params[:adults].to_i - extra_adults
    end

    def build_reservation(params)
      return Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: lodging, booking: Booking.new) if lodging.present?
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: room_rate.parent_lodging, room_rate: room_rate, booking: Booking.new)
    end
end
