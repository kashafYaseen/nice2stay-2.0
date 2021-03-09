  class RoomRaccoons::ValidatePrices
  attr_reader :body, :hotel_id, :prices

  def initialize(body:, hotel_id:)
    @body = body
    @prices = []
    @hotel_id = hotel_id
  end

  def self.call(body:, hotel_id:)
    new(body: body, hotel_id: hotel_id).call
  end

  def call
    begin
      if @body['rateamountmessages']['rateamountmessage'].is_a?(Array)
        @body['rateamountmessages']['rateamountmessage'].each do |rate_amount_message|
          prices << parse_data(rate_amount_message)
        end
      else
        prices << parse_data(@body['rateamountmessages']['rateamountmessage'])
      end

      Rails.logger.info "PARSED PRICES ===============================>>>>>>>>>> #{prices}"
      # dates = prices.map { |price| (price[:start_date]..price[:end_date]).map(&:to_s) }.flatten.uniq.sort
      # rooms = RoomType.where(parent_lodging_id: hotel_id).joins(:availabilities).by_codes(room_type_codes, rate_plan_codes).select('availabilities.available_on as available_on')
      rooms = RoomType.where(parent_lodging_id: hotel_id).by_codes room_type_codes, rate_plan_codes
      # rooms = rooms.select { |room| dates.include?(room.available_on.to_s) }
      return false if rooms.size.zero?

      Rails.logger.info '===============================>>>>>>>>>>In PRICES JOB'
      RrCreatePricesJob.perform_later(
        hotel_id: hotel_id,
        room_type_codes: room_type_codes,
        rate_plan_codes: rate_plan_codes,
        rr_prices: prices
      )
      true
    rescue => e
      Rails.logger.info "Error in Room Raccoon Prices============>: #{e}"
      false
    end
  end

  private
    def parse_data(data)
      room_type_code = data['statusapplicationcontrol']['invtypecode']
      rate_plan_code = data['statusapplicationcontrol']['rateplancode']
      start_date = data['statusapplicationcontrol']['start']
      end_date = data['statusapplicationcontrol']['end']

      base_by_guest_amts = data['rates']['rate']['basebyguestamts']['basebyguestamt']
      rates = []
      if base_by_guest_amts.kind_of?(Array)
        base_by_guest_amts.each do |base_by_guest_amt|
          rates << guests_base_amount(base_by_guest_amt)
        end
      else
        rates << guests_base_amount(base_by_guest_amts)
      end

      additional_guest_amounts = data['rates']['rate']['additionalguestamounts']
      if additional_guest_amounts.present?
        additional_amounts = []
        additional_guest_amounts = data['rates']['rate']['additionalguestamounts']['additionalguestamount']

        if additional_guest_amounts.is_a?(Array)
          additional_guest_amounts.each do |additional_guest_amount|
            additional_amounts << guests_additional_amount(additional_guest_amount)
          end
        else
          additional_amounts << guests_additional_amount(additional_guest_amounts)
        end
      end

      {
        room_type_code: room_type_code,
        rate_plan_code: rate_plan_code,
        start_date: start_date,
        end_date: end_date,
        rates: rates,
        additional_amounts: additional_amounts
      }
    end

    def guests_base_amount params
      {
        age_qualifying_code: params['agequalifyingcode'],
        # guests: params['numberofguests'].present? ? params['numberofguests'] : '999',
        guests: params['numberofguests'],
        amount: params['amountaftertax']
      }
    end

    def guests_additional_amount params
      {
        age_qualifying_code: params['agequalifyingcode'],
        amount: params['amount']
      }
    end

    def room_type_codes
      prices.map { |data| data[:room_type_code] }.uniq
    end

    def rate_plan_codes
      prices.map { |data| data[:rate_plan_code] }.uniq
    end
end
