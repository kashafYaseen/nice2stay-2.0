class SearchDiscounts
  attr_reader :params

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    results = Discount.search("*", where: conditions).results
    discounts = []
    results.each do |discount|
      discount.set_nights(dates)
      discounts << discount.invoice_features
    end
    discounts
  end

  private
    def conditions
      conditions = {}
      conditions[:dates] = dates
      conditions[:valid_to] = { gte: Date.today }
      conditions[:lodging_id] = params[:lodging_id]
      conditions[:minimum_days] = [total_nights, nil]
      conditions[:publish] = true

      conditions
    end

    def total_nights
      (params[:check_out].to_date - params[:check_in].to_date).to_i
    end

    def dates
      check_in = params[:check_in].presence || params[:check_out]
      check_out = params[:check_out].presence || params[:check_in]
      (Date.parse(check_in)..Date.parse(check_out).prev_day).map(&:to_s)
    end
end
