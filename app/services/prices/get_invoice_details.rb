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
    non_flexible_search unless lodging.flexible_search
  end

  private
    def non_flexible_search
      rates = results[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }
      total_price, nights = total_and_nights(rates)
      cleaning_cost = lodging.cleaning_cost_for((params[:adults].to_i + params[:children].to_i), nights)
      discount = total_discounts(params, total_price, nights)

      {
        rates: results[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h },
        search_params: results[:search_params],
        valid: results[:valid],
        errors: results[:errors],
        flexible: false,
        cleaning_cost: cleaning_cost,
        discount: discount,
        subtotal: (total_price + cleaning_cost),
        total: (total_price + cleaning_cost - discount),
      }
    end

    def total_discounts search_params, total_price, nights
      total_discount = 0
      lodging.discount(search_params).each do |discount|
        if discount[:percentage] == 'percentage'
          total_discount += (((total_price/nights) * discount[:total_nights]) * discount[:value]/100.to_f)
        else
          total_discount += (discount[:value] * discount[:total_nights])
        end
      end
      total_discount
    end

    def total_and_nights rates
      total, nights = 0, 0
      rates.each { |price, night| total, nights = (price * night) + total, night + nights }
      [total, nights]
    end
end
