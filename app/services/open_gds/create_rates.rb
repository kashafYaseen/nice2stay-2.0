class OpenGds::CreateRates
  attr_reader :rates

  def initialize(rates)
    @rates = rates
  end

  def self.call(rates)
    new(rates).call
  end

  def call
    rate_plans = []
    availabilities = []
    rules = []
    room_rates = []
    availabilities = []
    prices = []
    lodgings = Lodging.where(open_gds_property_id: rates.map do |rate|
                                                     rate[:property_id]
                                                   end).includes(room_types: { room_rates: [availabilities: :prices] })
    db_rate_plans = RatePlan.includes(:rule)
    rates.each do |rate|
      destroy_rate_plan_details params: rate, rate_plans: db_rate_plans
      rate_details = update_rate_plan params: rate, lodgings: lodgings, rate_plans: db_rate_plans
      rate_plans << rate_details[:rate_plan]
      rules << rate_details[:rule]
      room_rates << rate_details[:room_rates]
      availabilities << rate_details[:availabilities]
      prices << rate_details[:prices]
    end

    insert_rate rate_plans: rate_plans, rules: rules, room_rates: room_rates.flatten, availabilities: availabilities.flatten,
                prices: prices.flatten
  end

  private

  def destroy_rate_plan_details(params:, rate_plans:)
    accommodation_ids = params[:accommodations].map { |accomdation| accomdation[:accom_id] }
    if params[:init]
      RoomRate.joins(:room_type,
                     :rate_plan).where(room_types: { open_gds_accommodation_id: accommodation_ids }, rate_plans: { open_gds_rate_id: params[:rate_id] }).destroy_all
    else
      RoomRate.joins(:room_type,
                     :rate_plan).where.not(room_types: { open_gds_accommodation_id: accommodation_ids }).where(rate_plans: { open_gds_rate_id: params[:rate_id] }).destroy_all
      dates = if params[:valid_permanent]
                (Date.today..365.days.from_now).map(&:to_s)
              elsif params[:valid_from].present? && params[:valid_till].present?
                (params[:valid_from].to_date..params[:valid_till].to_date).map(&:to_s)
              else
                []
              end
      rate_plan = rate_plans.find { |rp| rp[:open_gds_rate_id] == params[:rate_id] }
      rate_plan.availabilities.where('available_on < ? or available_on > ?', dates[0], dates[-1]).destroy_all
    end
  end

  def update_rate_plan(params:, lodgings:, rate_plans:)
    room_rates = []
    availabilities = []
    prices = []
    dates = if params[:valid_permanent]
              (Date.today..365.days.from_now).map(&:to_s)
            elsif params[:valid_from].present? && params[:valid_till].present?
              (params[:valid_from].to_date..params[:valid_till].to_date).map(&:to_s)
            else
              []
            end

    lodging = lodgings.find { |lod| lod[:open_gds_property_id] == params[:property_id] }
    rate_plan = rate_plans.find { |rp| rp[:open_gds_rate_id] == params[:rate_id] }
    rate_plan.rate_enabled = params[:rate_enabled] if params[:rate_enabled].present?
    rate_plan.open_gds_rate_type = params[:rate_type] if params[:rate_type].present?
    rate_plan.open_gds_valid_permanent = params[:valid_pernament] if params[:valid_pernament].present?
    rate_plan.open_gds_res_fee = params[:res_fee] if params[:res_fee].present?
    rate_plan.open_gds_rate_type = params[:rate_type] if params[:rate_type].present?
    rate_plan.min_stay = params[:default_minlos] if params[:default_minlos].present?
    rate_plan.max_stay = params[:default_maxlos] if params[:default_maxlos].present?
    if rate_plan.new_record?
      rate_plan.created_at = DateTime.current
    elsif rate_plan.changed?
      rate_plan.updated_at = DateTime.current
    end

    rule = update_rule rate_params: params, rate_plan: rate_plan, lodging_id: lodging.id
    params[:accommodations].each do |accommodation|
      rate = update_room_rates(rate_params: params.merge({ dates: dates }), accom_params: accommodation,
                               room_types: lodging.room_types, rate_plan: rate_plan)
      room_rates << rate[:room_rate]
      availabilities << rate[:availabilities]
      prices << rate[:prices]
    end

    {
      rate_plan: rate_plan,
      rule: rule,
      room_rates: room_rates,
      availabilities: availabilities,
      prices: prices
    }
  end

  def update_room_rates(rate_params:, accom_params:, room_types:, rate_plan:)
    room_type = room_types.find { |rt| rt[:open_gds_accommodation_id] == accom_params[:accom_id] }
    room_rate = room_type.room_rates.find { |rr| rr[:rate_plan_id] == rate_plan.id }
    room_rate = room_type.room_rates.new(rate_plan: rate_plan) unless room_rate.present?
    room_rate.default_booking_limit = accom_params[:default_available] if accom_params[:default_available].present?
    room_rate.default_rate = accom_params[:default_rate] if accom_params[:default_rate].present?
    room_rate.currency_code = accom_params[:currency_code] if accom_params[:currency_code].present?
    if accom_params[:default_single_rate_type].present?
      room_rate.default_single_rate_type = accom_params[:default_single_rate_type]
    end
    room_rate.default_single_rate = accom_params[:default_single_rate] if accom_params[:default_single_rate].present?
    room_rate.extra_night_rate = accom_params[:extra_night_rate] if accom_params[:extra_night_rate].present?
    if room_rate.new_record?
      room_rate.created_at = DateTime.current
    elsif room_rate.changed?
      room_rate.updated_at = DateTime.current
    end

    availabilities, prices = update_availabilities(
      rate_params: rate_params, room_rate: room_rate, rate_plan: rate_plan
    )
    availabilities = room_rate.availabilities if availabilities.blank?
    update_availabilities_by_status(
      rate_plan: rate_plan, accom_params: accom_params, availabilities: availabilities, prices: prices
    )

    { room_rate: room_rate, availabilities: availabilities, prices: prices }
  end

  def update_availabilities(rate_params:, room_rate:, rate_plan:)
    availabilities = []
    prices = []
    params = {
      available: room_rate.default_booking_limit,
      rate: room_rate.default_rate,
      single_rate: room_rate.default_single_rate,
      minlos: rate_plan.min_stay,
      maxlos: rate_plan.max_stay
    }

    rate_params[:dates].each do |date|
      availability = room_rate.availabilities.find do |avail|
        avail[:available_on] == date.to_date
      end
      availability ||= room_rate.availabilities.new(available_on: date)
      availability = set_availability params: params, availability: availability
      availabilities << availability
      price = set_prices params: params, availability: availability
      prices << price if price.new_record? || price.changed?
    end

    [availabilities, prices]
  end

  def update_rule(rate_params:, rate_plan:, lodging_id:)
    rule = rate_plan.rule.present? ? rate_plan.rule : rate_plan.build_rule
    rule.start_date = rate_params[:valid_from] if rate_params[:valid_from].present?
    rule.end_date = rate_params[:valid_till] if rate_params[:valid_till].present?
    rule.open_gds_restriction_type = rate_params[:restriction_type] if rate_params[:restriction_type].present?
    rule.open_gds_restriction_days = rate_params[:restriction_days] if rate_params[:restriction_days].present?
    rule.open_gds_arrival_days = rate_params[:arrival_days] if rate_params[:arrival_days].present?
    if rule.new_record?
      rule.created_at = DateTime.current
    elsif rule.changed?
      rule.updated_at = DateTime.current
    end
    rule.lodging_id = lodging_id
    rule
  end

  def update_availabilities_by_status(rate_plan:, accom_params:, availabilities:, prices:)
    accom_params[:status]&.each do |accommodation_status|
      availability = availabilities.find do |avail|
        avail[:available_on] == accommodation_status[:date].to_date
      end

      params = {
        available: accommodation_status[:available],
        minlos: accommodation_status[:minlos] || rate_plan.min_stay,
        maxlos: accommodation_status[:maxlos] || rate_plan.max_stay,
        rate: accommodation_status[:daily_rate],
        single_rate: accommodation_status[:daily_single_rate],
        close_out: accommodation_status[:close_out],
        cta: accommodation_status[:cta],
        ctd: accommodation_status[:ctd]
      }
      availability = set_availability params: params, availability: availability
      price = set_prices params: params, availability: availability
      prices << price unless prices.include?(price)
    end
  end

  def set_availability(params:, availability:)
    if params[:close_out]
      availability.rr_booking_limit = 0
    elsif params[:available].present?
      availability.rr_booking_limit = params[:available]
    end

    stays = []
    stays << params[:minlos] if params[:minlos].present?
    stays << params[:maxlos] if params[:maxlos].present?
    availability.rr_minimum_stay = (stays[0]..stays[-1]).map(&:to_s) if stays.present?
    availability.rr_check_in_closed = params[:cta] if params[:cta].present?
    availability.rr_check_out_closed = params[:ctd] if params[:ctd].present?
    if availability.new_record?
      availability.created_at = DateTime.current
    elsif availability.changed?
      availability.updated_at = DateTime.current
    end
    availability
  end

  def set_prices(params:, availability:)
    price = availability.prices.find { |p| p[:adults] == ['999'] && p[:children] == ['999'] && p[:infants] == ['999'] }
    price = availability.prices.new(adults: ['999'], children: ['999'], infants: ['999']) unless price.present?
    stays = []
    stays << params[:minlos] if params[:minlos].present?
    stays << params[:maxlos] if params[:maxlos].present?
    price.amount = params[:rate] if params[:rate].present?
    price.minimum_stay = (stays[0]..stays[-1]).map(&:to_s) if stays.present?
    price.open_gds_single_rate = params[:single_rate] if params[:single_rate].present?
    if price.new_record?
      price.created_at = DateTime.current
    elsif price.changed?
      price.updated_at = DateTime.current
    end
    price
  end

  def insert_rate(rate_plans:, rules:, room_rates:, availabilities:, prices:)
    if rate_plans.present?
      RatePlan.import rate_plans, batch_size: 150,
                                  on_duplicate_key_update: { columns: %i[rate_enabled open_gds_valid_permanent open_gds_res_fee open_gds_rate_type min_stay max_stay updated_at] }
    end
    if rules.present?
      Rule.import rules.each { |rule|
                    rule.rate_plan_id = rule.rate_plan.id
                  }, batch_size: 150, on_duplicate_key_update: { columns: %i[start_date end_date open_gds_restriction_type open_gds_restriction_days open_gds_arrival_days updated_at] }
    end
    if room_rates.present?
      RoomRate.import room_rates.each { |room_rate|
                        room_rate.rate_plan_id = room_rate.rate_plan.id
                      }, batch_size: 150,
                         on_duplicate_key_update: { columns: %i[default_booking_limit default_rate currency_code default_single_rate_type default_single_rate extra_night_rate updated_at] }
    end
    if availabilities.present?
      availabilities = availabilities.flatten.select do |availability|
        availability.new_record? || availability.changed?
      end
      Availability.import availabilities.each { |availability|
                            availability.room_rate_id = availability.room_rate.id
                          }, batch_size: 150, on_duplicate_key_update: { columns: %i[rr_booking_limit rr_minimum_stay rr_check_in_closed rr_check_out_closed updated_at] }
    end
    if prices.present?
      Price.import prices.flatten.each { |price|
                     price.availability_id = price.availability.id
                   }, batch_size: 150, on_duplicate_key_update: { columns: %i[amount minimum_stay open_gds_single_rate adults children infants updated_at] }
    end
  end
end
