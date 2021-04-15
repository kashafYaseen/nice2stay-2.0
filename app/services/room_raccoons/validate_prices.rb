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
          parsed_price = parse_body(rate_amount_message)
          price = prices.find { |avail|
            avail[:lodging_id] == parsed_price[:lodging_id] && avail[:rate_plan_id] == parsed_price[:rate_plan_id] &&
              avail[:start_date] == parsed_price[:start_date] && avail[:end_date] == parsed_price[:end_date]
            }

          if price.present?
            price.merge!(parsed_price)
          else
            prices << parsed_price
          end
        end
      else
        prices << parse_body(@body['rateamountmessages']['rateamountmessage'])
      end

      Rails.logger.info "PARSED PRICES ===============================>>>>>>>>>> #{prices}"
      return false if Lodging.where(id: lodging_ids).count.zero?

      Rails.logger.info '===============================>>>>>>>>>>In PRICES JOB'
      RrCreatePricesJob.perform_later(
        hotel_id: hotel_id,
        lodging_ids: lodging_ids,
        rate_plan_ids: rate_plan_ids,
        rr_prices: prices
      )
      true
    rescue => e
      Rails.logger.info "Error in Room Raccoon Prices============>: #{e}"
      false
    end
  end

  private
    def parse_body params
      response = {}
      response[:lodging_id] = params['statusapplicationcontrol']['invtypecode']
      response[:rate_plan_id] = params['statusapplicationcontrol']['rateplancode']
      response[:start_date] = params['statusapplicationcontrol']['start']
      response[:end_date] = params['statusapplicationcontrol']['end']

      base_by_guest_amts = params['rates']['rate']['basebyguestamts']['basebyguestamt']
      rates = []
      if base_by_guest_amts.kind_of?(Array)
        base_by_guest_amts.each do |base_by_guest_amt|
          rates << guests_base_amount(base_by_guest_amt)
        end
      else
        rates << guests_base_amount(base_by_guest_amts)
      end

      response[:rates] = rates
      additional_guest_amounts = params['rates']['rate']['additionalguestamounts']
      if additional_guest_amounts.present?
        additional_amounts = []
        additional_guest_amounts = params['rates']['rate']['additionalguestamounts']['additionalguestamount']

        if additional_guest_amounts.is_a?(Array)
          additional_guest_amounts.each do |additional_guest_amount|
            additional_amounts << guests_additional_amount(additional_guest_amount)
          end
        else
          additional_amounts << guests_additional_amount(additional_guest_amounts)
        end

        response[:additional_amounts] = additional_amounts
      end

      response
    end

    def guests_base_amount params
      {
        age_qualifying_code: params['agequalifyingcode'],
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

    def lodging_ids
      prices.map { |data| data[:lodging_id] }.uniq
    end

    def rate_plan_ids
      prices.map { |data| data[:rate_plan_id] }.uniq
    end
end
