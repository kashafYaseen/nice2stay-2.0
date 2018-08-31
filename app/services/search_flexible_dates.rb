class SearchFlexibleDates
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
    required_dates = (params[:check_in]..params[:check_out]).to_a.map(&:to_s)
    available_dates = lodging.availabilities.for_range(params[:check_in], params[:check_out]).pluck(:available_on).map(&:to_s)
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
      price_list = SearchPrices.call(params).sort.uniq(&:available_on).pluck(:amount)
      price_list = price_list + [lodging.price] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      return { rates: price_list, search_params: params }
    end

    def search_price_with(params)
      price_list = SearchPrices.call(params).sort.uniq(&:available_on).pluck(:amount)
      price_list = price_list + [lodging.price] * (params[:minimum_stay] - price_list.size) if price_list.size < params[:minimum_stay]
      return { rates: price_list, search_params: params }
    end

    def available_for?(check_in, check_out)
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
end
