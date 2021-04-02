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
    def parse_data(data)
      lodging_id = data['statusapplicationcontrol']['invtypecode']
      rate_plan_id = data['statusapplicationcontrol']['rateplancode']
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
        lodging_id: lodging_id,
        rate_plan_id: rate_plan_id,
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

    def lodging_ids
      prices.map { |data| data[:lodging_id] }.uniq
    end

    def rate_plan_ids
      prices.map { |data| data[:rate_plan_id] }.uniq
    end
end
