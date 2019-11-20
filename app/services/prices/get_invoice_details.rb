class Prices::GetInvoiceDetails
  attr_reader :params
  attr_reader :lodging
  attr_reader :results

  def self.call(lodging, params)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @lodging = lodging
    @params = params
    @results = lodging.price_list(params)
  end

  def call
    return flexible_search if lodging.flexible_search
    non_flexible_search
  end

  private
    def flexible_search
      search_params = results.map{ |result| result[:search_params] }

      {
        rates: results.map{ |result| result[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }},
        flexible: true,
        search_params: search_params,
        valid: results.map{ |result| result[:valid] },
        cleaning_costs: cleaning_costs,
        discounts: discounts_list(search_params),
      }
    end

    def non_flexible_search
      {
        rates: results[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h },
        search_params: results[:search_params],
        valid: results[:valid],
        flexible: false,
        cleaning_costs: cleaning_costs,
        discounts: lodging.discount(params),
      }
    end

    def discounts_list search_params
      discounts = []
      search_params.each do |param|
        discounts << lodging.discount([param[:check_in], param[:check_out]])
      end
    end

    def cleaning_costs
      lodging.cleaning_costs.for_guests(params[:adults].to_i + params[:children].to_i)
    end
end
