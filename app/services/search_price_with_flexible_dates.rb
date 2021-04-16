class SearchPriceWithFlexibleDates
  attr_reader :params
  attr_reader :lodging

  FLEXIBILITY = 3

  def self.call(params, lodging)
    self.new(params, lodging).call
  end

  def initialize(params, lodging)
    @params = params
    @lodging = lodging
  end

  def call
    return search_price_with_defaults unless lodging.as_child? && params[:flexible]
    flexible_search
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
      price_list = []
      lodging.flexible_search = false
      applied_prices = SearchPrices.call(params)

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
      return { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
    end

    def search_price_with(params)
      price_list = SearchPrices.call(params).uniq(&:available_on).pluck(:amount)
      price_list = price_list + [lodging.price.to_f] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      reservation = build_reservation params
      return { rates: price_list, search_params: params, valid: reservation.validate, errors: reservation.errors }
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

    def build_reservation(params)
      Reservation.new(check_in: params[:check_in], check_out: params[:check_out], adults: params[:adults], children: params[:children], lodging: lodging, booking: Booking.new)
    end

    def reservation_dates
      (params[:check_in].to_date..(params[:check_out].to_date - 1.day)).to_a.map(&:to_s)
    end
end
