class RoomRaccoons::CreatePrices
  attr_reader :body
  attr_reader :hotel

  def initialize(body, hotel)
    @body = body
    @hotel = hotel
  end

  def self.call(body, hotel)
    self.new(body, hotel).call
  end

  def call
    begin
      if @body['rateamountmessages']['rateamountmessage'].kind_of?(Array)
        @body['rateamountmessages']['rateamountmessage'].each do |rate_amount_message|
          create_prices_and_cleaning_costs(rate_amount_message)
        end
      else
        create_prices_and_cleaning_costs(@body['rateamountmessages']['rateamountmessage'])
      end

      return true
    rescue
      return false
    end
  end

  private
    def parse_data(data)
      room_type_code = data['statusapplicationcontrol']['invtypecode']
      rate_plan_code = data['statusapplicationcontrol']['rateplancode']
      start_date = data['statusapplicationcontrol']['start'].to_date
      end_date = data['statusapplicationcontrol']['end'].to_date

      base_by_guest_amts = data['rates']['rate']['basebyguestamts']['basebyguestamt']
      rates = []
      if base_by_guest_amts.kind_of?(Array)
        base_by_guest_amts.each do |base_by_guest_amt|
          rates << base_by_guests_hash(base_by_guest_amt)
        end
      else
        rates << base_by_guests_hash(base_by_guest_amts)
      end

      additional_guest_amounts = data['rates']['rate']['additionalguestamounts']
      if additional_guest_amounts.present?
        additional_amounts = []
        additional_guest_amounts = data['rates']['rate']['additionalguestamounts']['additionalguestamount']

        if additional_guest_amounts.kind_of?(Array)
          additional_guest_amounts.each do |additional_guest_amount|
            additional_amounts << additional_guests_hash(additional_guest_amount)
          end
        else
          additional_amounts << additional_guests_hash(additional_guest_amounts)
        end
      end

      return room_type_code&.upcase, rate_plan_code&.upcase, start_date, end_date, rates, additional_amounts
    end

    def create_prices_and_cleaning_costs(rate_amount_message)
      room_type_code,
      rate_plan_code,
      start_date,
      end_date,
      rates,
      additional_amounts = parse_data(rate_amount_message)

      @rooms = hotel.room_types.find_by(code: room_type_code)&.child_lodgings.includes(:cleaning_costs, :rules, availabilities: :prices).where('availabilities.available_on >= ? and availabilities.available_on <= ?', start_date, end_date).references(:availabilities)

      new_prices = []
      new_cleaning_costs = []

      @rooms.each do |room|
        rule_index = room.rules.find_index {|rule| rule.start_date == start_date && rule.end_date == end_date }
        if rule_index.present?
          @rule = room.rules[rule_index]
        end

        room.availabilities.each do |availability|
          prices = availability.prices

          rates.each do |rate|
            if rate[:age_qualifying_code].present? && rate[:guests].present?
              @price_index = prices.find_index {|price|
                (rate[:age_qualifying_code] == "7" && price.infants == [rate[:guests]]) ||
                (rate[:age_qualifying_code] == "8" && price.children == [rate[:guests]]) ||
                (rate[:age_qualifying_code] == "10" && price.adults == [rate[:guests]])
              }
            else
              @price_index = prices.find_index {|price| !(price.children.present? || price.adults.present? || price.infants.present?) }
            end

            if @price_index.present?
              @price = prices[@price_index]
              @price.amount = rate[:amount]
            else
              @price = availability.prices.new(amount: rate[:amount], rr_rate_plan_code: rate_plan_code, created_at: DateTime.now, updated_at: DateTime.now)
            end

            if rate[:guests].present?
              if rate[:age_qualifying_code] == "7"
                @price.infants = [rate[:guests]]
              elsif rate[:age_qualifying_code] == "8"
                @price.children = [rate[:guests]]
              else
                @price.adults = [rate[:guests]]
              end
            else
              @price.infants = ["999"]
              @price.children = ["999"]
              @price.adults = ["999"]
            end

            if @rule.present?
              @price.minimum_stay = @rule.minimum_stay
            end

            if @price.new_record? || @price.changed?
              new_prices << @price
            end
          end
        end

        if additional_amounts.present?
          cleaning_costs = room.cleaning_costs

          additional_amounts.each do |additional_amount|
            cleaning_cost_index = cleaning_costs.find_index {|cleaning_cost|
              (additional_amount[:age_qualifying_code] == "7" && cleaning_cost.name == "Infants") ||
              (additional_amount[:age_qualifying_code] == "8" && cleaning_cost.name == "Children") ||
              (additional_amount[:age_qualifying_code] == "10" && cleaning_cost.name == "Adults")
            }

            if cleaning_cost_index.present?
              @cleaning_cost = cleaning_costs[cleaning_cost_index]
              @cleaning_cost.fixed_price = additional_amount[:amount]
            else
              @cleaning_cost = cleaning_costs.new(fixed_price: additional_amount[:amount], created_at: DateTime.now, updated_at: DateTime.now)
            end

            if additional_amount[:age_qualifying_code] == "7"
              @cleaning_cost.name = "Infants"
            elsif additional_amount[:age_qualifying_code] == "8"
              @cleaning_cost.name = "Children"
            else
              @cleaning_cost.name = "Adults"
            end

            if @cleaning_cost.new_record? || @cleaning_cost.changed?
              new_cleaning_costs << @cleaning_cost
            end
          end
        end
      end

      if new_prices.present?
        Price.import new_prices, batch_size: 150, on_duplicate_key_update: { columns: [:amount, :children, :infants, :adults, :minimum_stay] }
      end

      if new_cleaning_costs.present?
        CleaningCost.import new_cleaning_costs, batch: 150, on_duplicate_key_update: { columns: [:fixed_price, :name] }
      end
    end

    def base_by_guests_hash base_by_guest_amt
      {
        age_qualifying_code: base_by_guest_amt['agequalifyingcode'],
        guests: base_by_guest_amt['numberofguests'],
        amount: base_by_guest_amt['amountaftertax']
      }
    end

    def additional_guests_hash additional_guest_amount
      {
        age_qualifying_code: additional_guest_amount['agequalifyingcode'],
        amount: additional_guest_amount['amount']
      }
    end
end
