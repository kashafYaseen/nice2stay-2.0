class SearchPrices
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    first_attempt = Price.search query, where: first_attempt_conditions
    second_attempt_dates = dates_without_price(first_attempt, availability_condition)
    return first_attempt unless second_attempt_dates.present?
    second_attempt = Price.search query, where: second_attempt_conditions(second_attempt_dates)
    third_attempt_dates = dates_without_price(second_attempt, second_attempt_dates)
    return (first_attempt.results + second_attempt.results) unless third_attempt_dates.present?
    third_attempt = Price.search query, where: third_attempt_conditions(third_attempt_dates)
    (first_attempt.results + second_attempt.results + third_attempt.results)
  end

  private
    def query
      params[:query].presence || "*"
    end

    def first_attempt_conditions
      conditions = {}
      conditions[:available_on] = availability_condition
      conditions[:adults]   = params[:adults]
      conditions[:children] = params[:children]
      conditions[:lodging_child_id] = params[:lodging_child_id]
      conditions[:minimum_stay] = [params[:minimum_stay], nil]
      conditions
    end

    def second_attempt_conditions dates
      conditions = {}
      conditions[:available_on] = dates
      conditions[:adults]   = { gte: params[:adults] }
      conditions[:children] = { gte: params[:children] }
      conditions[:lodging_child_id] = params[:lodging_child_id]
      conditions[:minimum_stay] = [params[:minimum_stay], nil]
      conditions
    end

    def third_attempt_conditions dates
      conditions = {}
      conditions[:available_on] = dates
      conditions[:adults]  = { gte: params[:adults] }
      conditions[:lodging_child_id] = params[:lodging_child_id]
      conditions[:minimum_stay] = [params[:minimum_stay], nil]
      conditions[:adults_and_children] = { gte: (params[:adults].to_i + params[:children].to_i) }
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
end
