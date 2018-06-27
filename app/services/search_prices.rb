class SearchPrices
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Price.search query, where: conditions
  end

  private
    def query
      params[:query].presence || "*"
    end

    def conditions
      conditions = {}
      conditions[:available_on] = availability_condition
      conditions[:adults]   = params[:adults]
      conditions[:children] = params[:children]
      conditions[:infants]  = params[:infants]
      conditions[:lodging_child_id] = params[:lodging_child_id]
      conditions
    end

    def availability_condition
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      (check_in..check_out.to_date.prev_day.strftime('%Y-%m-%d')).map(&:to_s)
    end
end
