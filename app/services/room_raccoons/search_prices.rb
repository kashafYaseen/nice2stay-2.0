class RoomRaccoons::SearchPrices
  attr_reader :params,
              :first_condition,
              :second_condition

  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    dates = availability_condition
    result = Price.search(query, where: conditions(dates), order: order_by_attribute, includes: [:availability]).results
    dates = dates_without_price(result, availability_condition)
    return result unless dates.present?

    result + Price.search(query, where: conditions(dates), order: order_by_attribute, includes: [:availability]).results
  end

  private
    def query
      params[:query].presence || '*'
    end

    def conditions dates
      first_condition = {}
      first_condition[:_or] = []
      first_condition[:_or] << conditions_with(dates)
      first_condition
    end

    def conditions_with dates
      conditions = {}
      conditions[:_or] = []
      conditions[:_or] << condition_without_additional_amount
      conditions[:_or] << condition_with_additional_amount if params[:extra_adults].to_i.positive? || params[:children].to_i.positive?
      conditions[:available_on] = dates
      conditions[:room_rate_id] = params[:room_rate_id]
      conditions[:minimum_stay] = [params[:minimum_stay], 999]

      conditions
    end

    def condition_without_additional_amount
      conditions = {}
      conditions[:adults] = [params[:adults], 999]
      conditions[:rr_additional_amount_flag] = false
      conditions
    end

    def condition_with_additional_amount
      conditions = {}
      conditions[:_or] = []
      conditions[:_or] << { adults: [1, 999] } if params[:extra_adults].to_i.positive?
      conditions[:_or] << { children: [params[:children], 999] } if params[:children].to_i.positive?
      conditions[:rr_additional_amount_flag] = true
      conditions
    end

    def availability_condition
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      (Date.parse(check_in)..Date.parse(check_out).prev_day).map(&:to_s)
    end

    def dates_without_price(result, query_dates)
      query_dates - result.collect(&:available_on).map { |a| a.strftime('%Y-%m-%d') }
    end

    def order_by_attribute
      return { available_on: :asc } if params[:channel] == 'open_gds'

      { amount: :asc }
    end
end
