class SearchFlexibleDates
  attr_reader :params
  attr_reader :lodging

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

    if unavailable_dates.count == 0 || unavailable_dates.count > 3
      return search_price_with_defaults
    else
      diff = unavailable_dates.count
      loop do
        if available_for?(required_dates[diff], required_dates[-1])
          lodging.flexible_search = true
          return search_price_with(params.merge(check_in: required_dates[diff], minimum_stay: (params[:minimum_stay] - (diff-1))))
        elsif available_for?(required_dates[0], required_dates[-diff])
          lodging.flexible_search = true
          return search_price_with(params.merge(check_out: required_dates[-diff], minimum_stay: (params[:minimum_stay] - (diff-1))))
        end
        break if diff >= 3
        diff += 1
      end
    end
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
      available_dates = lodging.availabilities.for_range(check_in, check_out).pluck(:available_on).map(&:to_s)
      return true if (required_dates - available_dates).count == 0
      false
    end
end
