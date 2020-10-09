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
      if @body['ota_hotelrateamountnotifrq']['rateamountmessages']['rateamountmessage'].kind_of?(Array)
        @body['ota_hotelrateamountnotifrq']['rateamountmessages']['rateamountmessage'].each do |rate_amount_message|
          create_prices_and_cleaning_costs(rate_amount_message)
        end
      else
        create_prices_and_cleaning_costs(@body['ota_hotelrateamountnotifrq']['rateamountmessages']['rateamountmessage'])
      end

      true
    rescue
      false
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
          rates << {
            age_qualifying_code: base_by_guest_amt['agequalifyingcode'],
            guests: base_by_guest_amt['numberofguests'],
            amount: base_by_guest_amt['amountaftertax']
          }
        end
      else
        rates << {
          age_qualifying_code: base_by_guest_amt['agequalifyingcode'],
          guests: base_by_guest_amt['numberofguests'],
          amount: base_by_guest_amt['amountaftertax']
        }
      end

      additional_guest_amounts = data['rates']['rate']['additionalguestamounts']
      if additional_guest_amounts.present?
        additional_amounts = []
        additional_guest_amounts = data['rates']['rate']['additionalguestamounts']['additionalguestamount']
        additional_guest_amounts.each do |additional_guest_amount|
          additional_amounts << {
            age_qualifying_code: additional_guest_amount['agequalifyingcode'],
            amount: additional_guest_amount['amount']
          }
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
      rooms = hotel.room_types.find_by(code: room_type_code).child_lodgings

      rooms.each do |room|
        availabilities = room.availabilities.for_range(start_date, end_date)

        availabilities.each do |availability|
          rates.each do |rate|
            price = availability.prices.new(amount: rate[:amount])
            (rate[:age_qualifying_code].present? && rate[:age_qualifying_code] == "8") ? price.children = [rate[:guests]] : price.adults = [rate[:guests]]
            price.rr_rate_plan_code = rate_plan_code
            price.save
          end
        end

        if additional_amounts.present?
          additional_amounts.each do |additional_amount|
            room.cleaning_costs.create(
              fixed_price: additional_amount[:amount],
              name: additional_amount[:age_qualifying_code] == "10" ? "Adults" : "Children"
            )
          end
        end
      end
    end
end
