class OpenGds::CreateRates
  attr_reader :rates

  def initialize(rates)
    @rates = rates
  end

  def self.call(rates)
    new(rates).call
  end

  def call
    destroy_rate_plan_details
    rates.each do |rate|
      update_rate rate
    end
  end

  private

  def update_rate params
    rate_plans = []
    rules = []
    availabilities = []
    prices = []
    dates = if params[:valid_pernament]
              (Date.today..365.days.from_now).map(&:to_s)
            elsif params[:valid_from].present? && params[:valid_till].present?
              (params[:valid_from].to_date..params[:valid_till].to_date).map(&:to_s)
            else
              []
            end

    lodging = Lodging.find_by(open_gds_property_id: params[:property_id])
    room_types = lodging.room_types.includes(availabilities: :prices, rate_plans: :rule)
    params[:accommodations].each do |accommodation|
      rate = update_rate_plan(rate_params: params.merge({ dates: dates }), accom_params: accommodation, room_types: room_types, lodging: lodging)
      rate_plans << rate[:rate_plan]
      availabilities << rate[:availabilities]
      prices << rate[:prices]
      rules << rate[:rule]
    end

    RatePlan.import rate_plans, batch_size: 150, on_duplicate_key_update: { columns: %i[rate_enabled open_gds_valid_permanent open_gds_res_fee open_gds_rate_type updated_at] } if rate_plans.present?
    if availabilities.present?
      availabilities = availabilities.flatten.select { |availability| availability.new_record? || availability.changed? }
      Availability.import availabilities.each { |availability|
                            availability.rate_plan_id = availability.rate_plan.id
                          }, batch_size: 150, on_duplicate_key_update: { columns: %i[available_on rr_booking_limit rr_minimum_stay rr_check_in_closed rr_check_out_closed updated_at] }
    end

    Rule.import rules.each { |rule| rule.rate_plan_id = rule.rate_plan.id }, batch_size: 150, on_duplicate_key_update: { columns: %i[start_date end_date open_gds_restriction_type open_gds_restriction_days open_gds_arrival_days updated_at] } if rules.present?
    Price.import prices.flatten.each { |price| price.availability_id = price.availability.id }, batch_size: 150, on_duplicate_key_update: { columns: %i[amount minimum_stay open_gds_single_rate_type open_gds_single_rate open_gds_extra_night_rate adults children infants updated_at] } if prices.present?
  end

  def update_rate_plan(rate_params:, accom_params:, room_types:, lodging:)
    room_type = room_types.find { |rt| rt[:open_gds_accommodation_id] == accom_params[:accom_id] }
    rate_plan = room_type.rate_plans.find { |rp| rp[:open_gds_rate_id] == rate_params[:rate_id] }
    rate_plan = room_type.rate_plans.new(open_gds_rate_id: rate_params[:rate_id]) unless rate_plan.present?
    rate_plan.rate_enabled = rate_params[:rate_enabled] if rate_params[:rate_enabled].present?
    rate_plan.open_gds_valid_permanent = rate_params[:valid_pernament] if rate_params[:valid_pernament].present?
    rate_plan.open_gds_res_fee = rate_params[:res_fee] if rate_params[:res_fee].present?
    rate_plan.open_gds_rate_type = rate_params[:rate_type] if rate_params[:rate_type].present?
    if rate_plan.new_record?
      rate_plan.created_at = DateTime.current
    elsif rate_plan.changed?
      rate_plan.updated_at = DateTime.current
    end

    availabilities, prices = update_availabilities(
      rate_params: rate_params, accom_params: accom_params, room_type: room_type, rate_plan: rate_plan
    )
    rule = update_rule rate_params: rate_params, rate_plan: rate_plan, lodging: lodging
    availabilities = room_type.availabilities if availabilities.blank?
    update_availabilities_by_status(
      accom_params: accom_params, availabilities: availabilities, prices: prices, rate_plan: rate_plan
    )

    { rate_plan: rate_plan, availabilities: availabilities, prices: prices, rule: rule }
  end

  def update_availabilities(rate_params:, accom_params:, room_type:, rate_plan:)
    availabilities = []
    prices = []
    params = {
      available: accom_params[:default_available],
      minlos: rate_params[:default_minlos],
      maxlos: rate_params[:default_maxlos],
      rate: accom_params[:default_rate],
      single_rate_type: accom_params[:default_single_rate_type],
      single_rate: accom_params[:default_single_rate],
      extra_night_rate: accom_params[:extra_night_rate],
      rate_plan_id: rate_plan.id
    }

    rate_params[:dates].each do |date|
      availability = room_type.availabilities.find do |avail|
        avail[:available_on] == date.to_date && avail[:rate_plan_id] == rate_plan.id
      end
      unless availability.present?
        availability = room_type.availabilities.new(available_on: date,
                                                    rate_plan: rate_plan)
      end
      availability = set_availabilties params: params, availability: availability
      availabilities << availability
      price = set_prices params: params, availability: availability
      prices << price if price.new_record? || price.changed?
    end

    [availabilities, prices]
  end

  def update_rule(rate_params:, rate_plan:, lodging:)
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
    rule.lodging_id = lodging.id
    rule
  end

  def update_availabilities_by_status(accom_params:, availabilities:, prices:, rate_plan:)
    accom_params[:status]&.each do |accommodation_status|
      availability = availabilities.find do |avail|
        (avail[:available_on] == accommodation_status[:date].to_date) &&
          (
            (rate_plan.new_record? && avail.rate_plan == rate_plan) ||
            (!rate_plan.new_record? && avail[:rate_plan_id] == rate_plan.id)
          )
      end
      params = {
        available: accommodation_status[:available],
        minlos: accommodation_status[:minlos],
        maxlos: accommodation_status[:maxlos],
        rate: accommodation_status[:daily_rate],
        single_rate: accommodation_status[:daily_single_rate],
        close_out: accommodation_status[:close_out],
        cta: accommodation_status[:cta],
        ctd: accommodation_status[:ctd],
        rate_plan_id: rate_plan.id
      }
      availability = set_availabilties params: params, availability: availability
      price = set_prices params: params, availability: availability
      prices << price unless prices.include?(price)
    end
  end

  def set_availabilties(params:, availability:)
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
    availability.rate_plan_id = params[:rate_plan_id]
    availability.updated_at = DateTime.current unless availability.new_record? || !availability.changed?
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
    price.open_gds_single_rate_type = params[:single_rate_type] if params[:single_rate_type].present?
    price.open_gds_single_rate = params[:single_rate] if params[:single_rate].present?
    price.open_gds_extra_night_rate = params[:extra_night_rate] if params[:extra_night_rate].present?
    price.updated_at = DateTime.current unless price.new_record? || !price.changed?
    price
  end

  def destroy_rate_plan_details
    reload_rates = rates.select { |rate| rate[:init] }
    return unless reload_rates.present?

    RatePlan.where(open_gds_rate_id: reload_rates.map { |rate| rate[:rate_id] }).destroy_all
  end
end
