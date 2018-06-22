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
      end
    end
end
