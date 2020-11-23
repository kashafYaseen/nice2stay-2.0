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
    add_missing_availabilities
    clear_prices
    update_prices
    reindex_prices
  end

  private
    def update_prices
      begin
        import_list = []
        prices.each do |price_range|
          update_arrays(price_range)
          lodging.availabilities_for_range(price_range[:from], price_range[:to]).each do |availability|
            import_list << Price.new(amount: day_price(price_range, availability.available_on).to_f, children: price_range[:children], adults: price_range[:adults], checkin: price_range[:checkin],
              infants: price_range[:infants], minimum_stay: price_range[:minimal_stay], availability_id: availability.id, weekly_price: nil, created_at: Date.current, updated_at: Date.current)

            if price_range[:weekly_price].present? && price_range[:minimal_stay].exclude?('7')
              import_list << Price.new(amount: price_range[:amount].to_f, children: price_range[:children], adults: price_range[:adults], checkin: price_range[:checkin],
                infants: price_range[:infants], minimum_stay: ['7'], availability_id: availability.id, weekly_price: nil, created_at: Date.current, updated_at: Date.current)
            end
          end
          create_rule(price_range[:from], price_range[:to], price_range[:minimal_stay], price_range[:flexible_arrival], price_range[:checkin])
        end
        Price.import import_list
        true
      rescue
        false
      end
    end

    def add_missing_availabilities
      lodging.availabilities.check_out_only.destroy_all
      missing_dates = (Date.today..end_date).map(&:to_s) - lodging.availabilities.active.pluck(:available_on).map(&:to_s)
      lodging.add_availabilities_for missing_dates
    end

    def clear_prices
      Price.of_child(lodging.id).delete_all
      lodging.rules.destroy_all
    end

    def reindex_prices
      lodging.prices.reindex
    end

    def create_rule(from, to, minimal_stay, flexible_arrival, checkin_day)
      from = from.to_date.change(year: 2017) if from.to_date.year == 20117
      to = to.to_date.change(year: 2017) if to.to_date.year == 20117

      from = from.to_date.change(year: 2018) if from.to_date.year == 20118
      to = to.to_date.change(year: 2018) if to.to_date.year == 20118

      from = from.to_date.change(year: 2019) if from.to_date.year == 20119
      to = to.to_date.change(year: 2019) if to.to_date.year == 20119

      from = from.to_date.change(year: 2020) if from.to_date.year == 0202
      to = to.to_date.change(year: 2020) if to.to_date.year == 0202

      rule = lodging.rules.find_or_initialize_by(start_date: from, end_date: to, checkin_day: checkin_day)
      rule.flexible_arrival = flexible_arrival || lodging.flexible_arrival

      if rule.flexible_arrival
        rule.checkin_day = 'any'
      else
        rule.checkin_day = checkin_day == 'any' ? lodging.check_in_day : checkin_day
      end

      rule.minimum_stay |= minimal_stay.map(&:to_i)
      if rule.minimum_stay.min >= 8
        rule.minimum_stay |= [7]
        rule.minimum_stay.delete(999)
      end

      if minimal_stay.map(&:to_i).include?(999) && minimal_stay.length == 1
        rule.minimum_stay |= [7, 14, 21]
        rule.minimum_stay.delete(999)
      end
      rule.minimum_stay |= [7] if rule.minimum_stay.include?(6) && rule.minimum_stay.include?(8) && rule.minimum_stay.exclude?(7)
      rule.minimum_stay |= [14] if rule.minimum_stay.include?(13) && rule.minimum_stay.include?(15) && rule.minimum_stay.exclude?(14)
      rule.minimum_stay = rule.minimum_stay.sort.uniq
      rule.save
    end

    def day_price(price_range, available_on)
      return price_range[:sunday_price]    if available_on.wday == 0 && price_range[:sunday_price].present?
      return price_range[:monday_price]    if available_on.wday == 1 && price_range[:monday_price].present?
      return price_range[:tuesday_price]   if available_on.wday == 2 && price_range[:tuesday_price].present?
      return price_range[:wednesday_price] if available_on.wday == 3 && price_range[:wednesday_price].present?
      return price_range[:thursday_price]  if available_on.wday == 4 && price_range[:thursday_price].present?
      return price_range[:friday_price]    if available_on.wday == 5 && price_range[:friday_price].present?
      return price_range[:saturday_price]  if available_on.wday == 6 && price_range[:saturday_price].present?

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

    def end_date
      return '31-12-2021'.to_date if 365.days.from_now < '31-12-2021'.to_date
      365.days.from_now
    end
end
