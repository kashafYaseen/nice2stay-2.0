class SearchPrices
  attr_reader :params
  attr_reader :first_condition
  attr_reader :second_condition

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    set_conditions
  end

  def call
    result = Price.search(query, where: first_condition, order: order_by_attribute, includes: [:availability]).results
    query_dates = dates_without_price(result, availability_condition)
    return result unless query_dates.present?
    result += Price.search(query, where: second_condition, order: order_by_attribute, includes: [:availability]).results
  end

  private
    def query
      params[:query].presence || "*"
    end

    def set_conditions
      @first_condition = {}
      first_condition[:_or] = []

      @second_condition = {}
      second_condition[:_or] = []

      loop do
        first_condition[:_or] << conditions_with(availability_condition, false)
        second_condition[:_or] << conditions_with(availability_condition, true)
        break if params[:adults].to_i >= params[:max_adults].to_i || params[:children].to_i <= 0
        params[:adults] = (params[:adults].to_i + 1 ).to_s
        params[:children] = (params[:children].to_i - 1).to_s
      end
      second_condition[:_or] = second_condition[:_or].reverse
    end

    def conditions_with dates, flexible_children
      conditions = {}
      conditions[:_or] = []
      conditions[:available_on] = dates
      conditions[:adults] = [params[:adults], 999]

      if params[:channel] == 'open_gds'
        conditions[:minimum_stay] = [params[:minimum_stay], 999]
        conditions[:room_rate_id] = params[:room_rate_id]
        conditions[:multiple_checkin_days] = checkin_day
        conditions[:children] = flexible_children ? { gte: params[:children] } : params[:children]
      else
        conditions[:lodging_id] = params[:lodging_id]
        if flexible_children
          conditions[:children] = { gte: params[:children] }
        else
          conditions[:children] = params[:children]
        end
      end

      conditions
    end

    def availability_condition
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      (Date.parse(check_in)..Date.parse(check_out).prev_day).map(&:to_s)
    end

    def dates_without_price(result, query_dates)
      query_dates - result.collect(&:available_on).map{ |a| a.strftime('%Y-%m-%d') }
    end

    def checkin_day
      check_in = params[:check_in].presence || params[:check_out]
      Date.parse(check_in).strftime("%A").downcase
    end

    def order_by_attribute
      return { available_on: :asc } if params[:channel] == 'open_gds'

      { amount: :asc }
    end
end
