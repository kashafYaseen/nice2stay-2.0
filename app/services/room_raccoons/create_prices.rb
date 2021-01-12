class RoomRaccoons::CreatePrices
  attr_reader :hotel_id, :room_type_codes, :rate_plan_codes, :rr_prices

  def self.call(hotel_id, room_type_codes, rate_plan_codes, rr_prices)
    self.new(hotel_id, room_type_codes, rate_plan_codes, rr_prices).call
  end

  def initialize(hotel_id, room_type_codes, rate_plan_codes, rr_prices)
    @hotel_id = hotel_id
    @room_type_codes = room_type_codes
    @rate_plan_codes = rate_plan_codes
    @rr_prices = rr_prices
  end

  def call
    hotel_room_types = RoomType.includes(availabilities: %i[rate_plan prices cleaning_costs]).where(parent_lodging_id: hotel_id).by_codes room_type_codes, rate_plan_codes
    new_prices = []
    new_cleaning_costs = []

    rr_prices.each do |rr_price|
      dates = (rr_price[:start_date].to_date..rr_price[:end_date].to_date).map(&:to_s)
      current_room_type = hotel_room_types.find { |room_type| room_type.code == rr_price[:room_type_code] }
      current_room_rate = current_room_type.room_rates.find { |room_rate| room_rate.rate_plan_code == rr_price[:rate_plan_code] }
      availabilities = current_room_rate.availabilities.select { |availability| dates.include?(availability.available_on.to_s) }

      availabilities.each do |availability|
        prices = availability.prices
        rr_price[:rates].each do |rate|
          if rate[:age_qualifying_code].present?
            @price_index = prices.find_index { |price|
              (rate[:age_qualifying_code] == '7' && price.infants == [rate[:guests]]) ||
              (rate[:age_qualifying_code] == '8' && price.children == [rate[:guests]]) ||
              (rate[:age_qualifying_code] == '10' && price.adults == [rate[:guests]])
            }
          else
            @price_index = prices.find_index { |price| !(price.children.present? || price.adults.present? || price.infants.present?) }
          end

          if @price_index.present?
            @price = prices[@price_index]
            @price.amount = rate[:amount]
          else
            @price = availability.prices.new(amount: rate[:amount], created_at: DateTime.now, updated_at: DateTime.now)
          end

          case rate[:age_qualifying_code]
          when '7'
            @price.infants = [rate[:guests]]
          when '8'
            @price.children = [rate[:guests]]
          else
            @price.adults = [rate[:guests]]
          end

          @price.minimum_stay = availability.rr_minimum_stay
          new_prices << @price if @price.new_record? || @price.changed?
        end

        next unless rr_price[:additional_amounts].present?

        cleaning_costs = availability.cleaning_costs
        rr_price[:additional_amounts].each do |additional_amount|
          cleaning_cost_index = cleaning_costs.find_index { |cleaning_cost|
            (additional_amount[:age_qualifying_code] == '7' && cleaning_cost.name == 'Infants') ||
              (additional_amount[:age_qualifying_code] == '8' && cleaning_cost.name == 'Children') ||
              (additional_amount[:age_qualifying_code] == '10' && cleaning_cost.name == 'Adults')
          }

          if cleaning_cost_index.present?
            @cleaning_cost = cleaning_costs[cleaning_cost_index]
            @cleaning_cost.fixed_price = additional_amount[:amount]
          else
            @cleaning_cost = cleaning_costs.new(fixed_price: additional_amount[:amount], created_at: DateTime.now, updated_at: DateTime.now)
          end

          case additional_amount[:age_qualifying_code]
          when '7'
            @cleaning_cost.name = 'Infants'
          when '8'
            @cleaning_cost.name = 'Children'
          else
            @cleaning_cost.name = 'Adults'
          end

          new_cleaning_costs << @cleaning_cost if @cleaning_cost.new_record? || @cleaning_cost.changed?
        end
      end
    end

    if new_prices.present?
      Price.import new_prices, batch_size: 150, on_duplicate_key_update: { columns: %i[amount children infants adults minimum_stay] }
      new_prices.each(&:reindex)
    end
    CleaningCost.import new_cleaning_costs, batch: 150, on_duplicate_key_update: { columns: %i[fixed_price name] } if new_cleaning_costs.present?
  end
end
