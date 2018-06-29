class UpdateLodgingPrices
  attr_reader :lodging
  attr_reader :prices

  def self.call(lodging, prices)
    self.new(lodging, prices).call
  end

  def initialize(lodging, prices)
    @lodging = lodging
    @prices = prices
  end

  def call
    return unless prices.present?
    update_prices
  end

  private
    def update_prices
      prices.each do |price|
        _prices = lodging.prices_with_in(price[:from], price[:to])
        _prices.update_all(amount: price[:amount], children: price[:children], adults: price[:adults], infants: price[:infants]) if _prices.present?
        create_rule(price[:from], price[:to], price[:minimal_stay]) if price[:minimal_stay].present?
      end
    end

    def create_rule(from, to, minimal_stay)
      rule = lodging.rules.find_or_initialize_by(start_date: from, end_date: to)
      rule.minimal_stay = minimal_stay
      rule.save
    end
end
