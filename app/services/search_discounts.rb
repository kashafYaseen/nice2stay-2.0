class SearchDiscounts
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    Discount.search("*", where: conditions).results
  end

  private
    def conditions
      conditions = {}
      conditions[:start_date] = { lte: params[:check_in] }
      conditions[:end_date] = { gte: params[:check_out] }
      conditions[:lodging_id] = params[:lodging_id]
      conditions[:minimum_days] = [total_nights, nil]

      conditions
    end

    def total_nights
      (params[:check_out].to_date - params[:check_in].to_date).to_i
    end
end
