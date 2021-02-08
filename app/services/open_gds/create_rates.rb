class OpenGds::CreateRates
  attr_reader :rates,
              :lodgings,
              :rate_plans

  def initialize(rates)
    @rates = rates
    @lodgings = Lodging.where(id: rates.pluck(:property_interface_id)).includes(room_types: { room_rates: [availabilities: :prices] })
    @rate_plans = RatePlan.includes(:room_rates, :child_rates, rule: :lodging)
  end

  def self.call(rates)
    new(rates).call
  end

  def call
    updated_rate_plans = []
    updated_availabilities = []
    updated_rules = []
    updated_room_rates = []
    updated_prices = []
    updated_child_rates = []
    rates.each do |rate|
      destroy_rate_plan_details(rate)
      rate_details = update_rate_plan(rate)
      updated_rate_plans << rate_details[:rate_plans]
      updated_rules << rate_details[:rules]
      updated_child_rates << rate_details[:child_rates]
      updated_room_rates << rate_details[:room_rates]
      updated_availabilities << rate_details[:availabilities]
      updated_prices << rate_details[:prices]
    end

    insert_rate updated_rate_plans.flatten, updated_rules.flatten, updated_child_rates.flatten, updated_room_rates.flatten, updated_availabilities.flatten, updated_prices.flatten
  end

  private
    def destroy_rate_plan_details(params)
      accommodation_ids = params[:accommodations].map { |accomdation| accomdation[:accom_interface_id] }
      if params[:init]
        RoomRate.include_room_types_by_rate_plan(accommodation_ids, params[:rate_interface_id]).lodging_channel(3).destroy_all
      else
        RoomRate.exclude_room_types_by_rate_plan(accommodation_ids, params[:rate_interface_id]).lodging_channel(3).destroy_all
        dates = get_dates params
        selected_rate_plans = rate_plans.select { |rp| params[:rate_interface_id].map(&:to_i).include?(rp[:id]) }
        Availability.joins(:parent_lodging, :rate_plan).with_in(dates[0], dates[-1]).where(rate_plans: { id: selected_rate_plans.map(&:id) }, lodgings: { channel: 3 }).destroy_all
      end
    end

    def update_rate_plan(params)
      updated_rate_plans = []
      updated_rules = []
      updated_room_rates = []
      updated_availabilities = []
      updated_prices = []
      updated_child_rates = []

      lodging = lodgings.find { |lod| lod[:id] == params[:property_interface_id].to_i }
      selected_rate_plans = rate_plans.select { |rp| params[:rate_interface_id].map(&:to_i).include?(rp[:id]) }
      params = params.merge({ dates: get_dates(params) })
      selected_rate_plans.each do |rate_plan|
        rate_plan.rate_enabled = params[:rate_enabled] if params[:rate_enabled].present?
        rate_plan.open_gds_rate_type = params[:rate_type] if params[:rate_type].present?
        rate_plan.open_gds_valid_permanent = params[:valid_pernament] if params[:valid_pernament].present?
        rate_plan.open_gds_res_fee = params[:res_fee] if params[:res_fee].present?
        rate_plan.open_gds_rate_type = params[:rate_type] if params[:rate_type].present?
        rate_plan.min_stay = params[:default_minlos] if params[:default_minlos].present?
        rate_plan.max_stay = params[:default_maxlos] if params[:default_maxlos].present?
        rate_plan.open_gds_daily_supplements = params[:daily_supplement].to_h if params[:daily_supplement].present?
        rate_plan.open_gds_single_rate_type = params[:single_rate_type] if params[:single_rate_type].present?
        rate_plan.open_gds_rate_id = params[:rate_id]

        rule = update_rule params, rate_plan, lodging.id
        new_child_rates = update_child_rates params, rate_plan
        params[:accommodations].each do |accommodation|
          rate = update_room_rate(params, accommodation, lodging.room_types, rate_plan)
          updated_room_rates << rate[:room_rate]
          updated_availabilities << rate[:availabilities]
          updated_prices << rate[:prices]
        end
        updated_rate_plans << rate_plan if rate_plan.changed?
        updated_rules << rule if rule.new_record? || rule.changed?
        updated_child_rates << new_child_rates
      end
      {
        rate_plans: updated_rate_plans,
        rules: updated_rules,
        child_rates: updated_child_rates,
        room_rates: updated_room_rates,
        availabilities: updated_availabilities,
        prices: updated_prices
      }
    end

    def update_child_rates(rate_params, rate_plan)
      child_rates = []
      if rate_params[:child_rate].present?
        rate_params[:child_rate].keys.map(&:to_s).each do |child_key|
          child_rate = rate_plan.child_rates.find { |cr| cr[:open_gds_category].to_s == child_key } || rate_plan.child_rates.new(open_gds_category: child_key, created_at: DateTime.now)
          child_rate_params = rate_params[:child_rate][:"#{child_key}"]
          child_rate.rate = child_rate_params[:rate] if child_rate_params[:rate].present?
          child_rate.rate_type = child_rate_params[:type] if child_rate_params[:type].present?
          child_rate.age_group = child_age_group child_key
          child_rates << child_rate if child_rate.new_record? || child_rate.changed?
        end
      end

      child_rates
    end

    def update_room_rate(rate_params, accom_params, room_types, rate_plan)
      room_type = room_types.find { |rt| rt[:id] == accom_params[:accom_interface_id].to_i }
      room_rate = room_type.room_rates.find { |rr| rr[:rate_plan_id] == rate_plan.id } || room_type.room_rates.new(rate_plan: rate_plan)
      room_rate.default_booking_limit = accom_params[:default_available] if accom_params[:default_available].present?
      room_rate.default_rate = accom_params[:default_rate] if accom_params[:default_rate].present?
      room_rate.currency_code = accom_params[:currency_code] if accom_params[:currency_code].present?
      room_rate.default_single_rate_type = accom_params[:default_single_rate_type] if accom_params[:default_single_rate_type].present?
      room_rate.default_single_rate = accom_params[:default_single_rate] if accom_params[:default_single_rate].present?
      room_rate.extra_bed_rate = accom_params[:extra_bed_rate] if accom_params[:extra_bed_rate].present?
      room_rate.extra_bed_rate_type = accom_params[:extra_bed_rate_type] if accom_params[:extra_bed_rate_type].present?
      room_rate.extra_night_rate = accom_params[:extra_night_rate] if accom_params[:extra_night_rate].present?
      if room_rate.new_record?
        room_rate.created_at = DateTime.current
        room_rate.updated_at = DateTime.current
      end

      availabilities, prices = update_availabilities rate_params, room_rate, rate_plan
      availabilities = room_rate.availabilities if availabilities.blank?
      prices = prices.flatten
      update_availabilities_by_status rate_plan, accom_params, room_rate, availabilities, prices
      { room_rate: room_rate, availabilities: availabilities, prices: prices }
    end

    def update_availabilities(rate_params, room_rate, rate_plan)
      availabilities = []
      prices = []
      params = {
        available: room_rate.default_booking_limit,
        rate: room_rate.default_rate,
        single_rate: room_rate.default_single_rate,
        minlos: rate_plan.min_stay,
        maxlos: rate_plan.max_stay,
        checkin_days: rate_plan.open_gds_arrival_days
      }

      rate_params[:dates].each do |date|
        availability = room_rate.availabilities.find do |avail|
          avail[:available_on] == date.to_date
        end

        availability ||= room_rate.availabilities.new(available_on: date)
        availability = set_availability params, availability
        availabilities << availability
        price = set_price params, availability
        prices << price if price.new_record? || price.changed?
      end

      [availabilities, prices]
    end

    def update_rule(rate_params, rate_plan, lodging_id)
      rule = rate_plan.rule || rate_plan.build_rule
      rule.start_date = rate_params[:dates][0] if rate_params[:dates][0].present?
      rule.end_date = rate_params[:dates][-1] if rate_params[:dates][-1].present?
      rule.open_gds_restriction_type = rate_params[:restriction_type] if rate_params[:restriction_type].present?
      rule.open_gds_restriction_days = rate_params[:restriction_days] if rate_params[:restriction_days].present?
      rule.open_gds_arrival_days = checkin_days(rate_params[:arrival_days]) if rate_params[:arrival_days].present?
      if rule.new_record?
        rule.created_at = DateTime.current
        rule.updated_at = DateTime.current
      end

      rule.lodging_id = lodging_id
      rule
    end

    def update_availabilities_by_status(rate_plan, accom_params, room_rate, availabilities, prices)
      accom_params[:status]&.each do |accommodation_status|
        availability = availabilities.find do |avail|
          avail[:available_on] == accommodation_status[:date].to_date
        end

        availability ||= room_rate.availabilities.new(available_on: accommodation_status[:date])
        params = {
          available: accommodation_status[:available],
          minlos: accommodation_status[:minlos] || rate_plan.min_stay,
          maxlos: accommodation_status[:maxlos] || rate_plan.max_stay,
          rate: accommodation_status[:daily_rate],
          single_rate: accommodation_status[:daily_single_rate],
          close_out: accommodation_status[:close_out],
          cta: accommodation_status[:cta],
          ctd: accommodation_status[:ctd],
          checkin_days: rate_plan.open_gds_arrival_days
        }

        availability = set_availability params, availability
        price = set_price params, availability
        prices << price if prices.exclude?(price)
      end
    end

    def set_availability(params, availability)
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
        availability.updated_at = DateTime.current
      end
      availability
    end

    def set_price(params, availability)
      price = availability.prices.find { |p| p[:adults] == ['999'] && p[:children] == ['0'] && p[:infants] == ['0'] } || availability.prices.new(adults: ['999'], children: ['0'], infants: ['0'])
      price.amount = params[:rate] if params[:rate].present?
      price.minimum_stay = availability.rr_minimum_stay
      price.open_gds_single_rate = params[:single_rate] if params[:single_rate].present?
      price.multiple_checkin_days = params[:checkin_days] if params[:checkin_days].present?
      if price.new_record?
        price.created_at = DateTime.current
        price.updated_at = DateTime.current
      end
      price
    end

    def get_dates(params)
      return (Date.today..365.days.from_now).map(&:to_s) if params[:valid_permanent]
      return (params[:valid_from].to_date..params[:valid_till].to_date).map(&:to_s) if params[:valid_from].present? && params[:valid_till].present?

      []
    end

    def checkin_days(params)
      params.map { |arrival_day| get_full_day_name(arrival_day) }
    end

    def get_full_day_name(day)
      case day
      when 'Mon'
        'monday'
      when 'Tue'
        'tuesday'
      when 'Wed'
        'wednesday'
      when 'Thu'
        'thursday'
      when 'Fri'
        'friday'
      when 'Sat'
        'saturday'
      else
        'sunday'
      end
    end

    def child_age_group category
      return 0 if %w[1 2].include? category

      1
    end

    def insert_rate(rate_plans, rules, child_rates, room_rates, availabilities, prices)
      RatePlan.import rate_plans, batch_size: 150, on_duplicate_key_update: { columns: RatePlan.column_names - %w[id updated_at] } if rate_plans.present?
      Rule.import rules, batch_size: 150, on_duplicate_key_update: { columns: Rule.column_names - %w[id updated_at] } if rules.present?
      ChildRate.import child_rates, batch_size: 150, on_duplicate_key_update: { columns: %i[rate rate_type age_group] } if child_rates.present?
      RoomRate.import room_rates, batch_size: 150, on_duplicate_key_update: { columns: RoomRate.column_names - %w[id updated_at] } if room_rates.present?

      if availabilities.present?
        availabilities = availabilities.flatten.select do |availability|
          availability.new_record? || availability.changed?
        end
        availabilities.each { |availability| availability.room_rate_id = availability.room_rate.id }
        Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: Availability.column_names - %w[id updated_at] }
      end

      if prices.present?
        prices.each { |price| price.availability_id = price.availability.id }
        Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: Price.column_names - %w[id updated_at] }
        prices.each(&:reindex)
      end
    end
end
