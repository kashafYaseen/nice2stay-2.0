class RoomRaccoons::SearchPrices
  attr_reader :params

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    dates = availability_condition
    result = Price.search(query, where: conditions(dates), order: { available_on: :asc }, includes: [:availability]).results
    dates = dates_without_price(result.reject(&:rr_additional_amount_flag), availability_condition)
    return result unless dates.present?

    result + Price.search(query, where: conditions(dates, true), order: { available_on: :asc }, includes: [:availability]).results
  end

  private
    def query
      params[:query].presence || '*'
    end

    def conditions dates, flexible_adults = false
      condition = {}
      condition[:_or] = []
      condition[:_or] << conditions_with(dates, flexible_adults)
      condition
    end

    def conditions_with dates, flexible_adults
      condition = {}
      condition[:_or] = []
      condition[:_or] << condition_without_additional_amount(flexible_adults)
      condition[:_or] << condition_with_additional_amount if (params[:extra_adults].to_i.positive? || params[:children].to_i.positive?) && !flexible_adults
      condition[:available_on] = dates
      condition[:room_rate_id] = params[:room_rate_id]
      # condition[:minimum_stay] = [params[:minimum_stay], 999]

      condition
    end

    def condition_without_additional_amount(flexible_adults)
      condition = {}
      condition[:adults] = flexible_adults ? [params[:adults], 999] : [params[:adults]]
      condition[:rr_additional_amount_flag] = false
      condition
    end

    def condition_with_additional_amount
      condition = {}
      condition[:_or] = []
      condition[:_or] << { adults: [1, 999] } if params[:extra_adults].to_i.positive?
      condition[:_or] << { children: [1, 999] } if params[:children].to_i.positive?
      condition[:rr_additional_amount_flag] = true
      condition
    end

    def availability_condition
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      (Date.parse(check_in)..Date.parse(check_out).prev_day).map(&:to_s)
    end

    def dates_without_price(result, query_dates)
      query_dates - result.collect(&:available_on).map { |a| a.strftime('%Y-%m-%d') }
    end
end
