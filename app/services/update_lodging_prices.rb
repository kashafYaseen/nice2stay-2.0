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
    clear_prices
    update_prices
  end

  private
    def update_prices
      prices.each do |price_range|
        Price.bulk_insert do |price|
          lodging.availabilities_with_in(price_range[:from], price_range[:to]).each do |availability|
            price_range[:minimal_stay].each do |minimal_stay|
              price.add(amount: day_price(price_range, availability.available_on), children: price_range[:children], adults: price_range[:adults],
                infants: price_range[:infants], minimum_stay: minimal_stay, availability_id: availability.id)
            end
          end
        end
        create_rule(price_range[:from], price_range[:to], price_range[:minimal_stay], lodging.check_in_day) if price_range[:minimal_stay].present?
      end
    end

    def clear_prices
      lodging.lodging_children.each do |child|
        Price.of_child(child.id).delete_all
      end
    end

    def create_rule(from, to, minimal_stay, check_in_day)
      rule = lodging.rules.find_or_initialize_by(start_date: from, end_date: to)
      rule.minimal_stay = minimal_stay
      rule.check_in_days = check_in_day
      rule.save
    end

    def day_price(price_range, available_on)
      return price_range[:sunday_price] if available_on.wday == 0 && price_range[:sunday_price].present?
      return price_range[:friday_price] if available_on.wday == 5 && price_range[:friday_price].present?
      return price_range[:saturday_price] if available_on.wday == 6 && price_range[:saturday_price].present?
      price_range[:minimum_per_day_price] || price_range[:amount]
    end
end
