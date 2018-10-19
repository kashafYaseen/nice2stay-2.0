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
    reindex_prices
  end

  private
    def update_prices
      prices.each do |price_range|
        Price.bulk_insert do |price|
          update_arrays(price_range)
          lodging.availabilities_for_range(price_range[:from], price_range[:to]).each do |availability|
            price.add(amount: day_price(price_range, availability.available_on), children: price_range[:children], adults: price_range[:adults],
              infants: price_range[:infants], minimum_stay: price_range[:minimal_stay], availability_id: availability.id, weekly_price: nil, created_at: Date.current, updated_at: Date.current)

            if price_range[:weekly_price].present?
              price.add(amount: price_range[:amount], children: price_range[:children], adults: price_range[:adults],
                infants: price_range[:infants], minimum_stay: ['7'], availability_id: availability.id, weekly_price: nil, created_at: Date.current, updated_at: Date.current) if availability.price_with(price_range[:adults], price_range[:children], price_range[:amount], ['7']).blank?
            end
          end
        end
        create_rule(price_range[:from], price_range[:to], price_range[:minimal_stay], price_range[:flexible_arrival])
      end
    end

    def clear_prices
      Price.of_child(lodging.id).delete_all
    end

    def reindex_prices
      lodging.prices.reindex
    end

    def create_rule(from, to, minimal_stay, flexible_arrival)
      rule = lodging.rules.find_or_initialize_by(start_date: from, end_date: to)
      rule.flexible_arrival = flexible_arrival || lodging.flexible_arrival
      if minimal_stay.map(&:to_i).min == 999
        rule.minimum_stay = nil
      else
        rule.minimum_stay = minimal_stay.map(&:to_i).min unless rule.minimum_stay.present? && rule.minimum_stay < minimal_stay.map(&:to_i).min
        rule.minimum_stay = 7 if rule.minimum_stay == 8
      end
      rule.save
    end

    def day_price(price_range, available_on)
      return price_range[:sunday_price] if available_on.wday == 0 && price_range[:sunday_price].present?
      return price_range[:friday_price] if available_on.wday == 5 && price_range[:friday_price].present?
      return price_range[:saturday_price] if available_on.wday == 6 && price_range[:saturday_price].present?
      price_range[:minimal_price_per_day] || price_range[:amount]
    end

    def update_arrays(price_range)
      [price_range[:adults], price_range[:children], price_range[:infants]].each{ |values| values.delete('') }
      price_range[:minimal_stay] = []  if price_range[:minimal_stay].map(&:empty?).all?
      return price_range[:adults] = price_range[:children] = price_range[:infants] = ['999'] if price_range.values_at(:adults, :children, :infants).map(&:empty?).all?
      price_range[:children] = ['0'] if price_range[:children] == []
      price_range[:adults]   = ['0'] if price_range[:adults] == []
      price_range[:infants]  = ['0'] if price_range[:infants] == []
    end
end
