class OpenGds::CreateRates
  attr_reader :rates

  def initialize(rates)
    @rates = rates
  end

  def self.call(rates)
    # begin
      new(rates).call
      return false
    # rescue => e
      # Rails.logger.info "Error OpenGDS PUSH API ==========================>: #{e}"
      # return false
    # end
  end

  def call
    destroy_rate_plan_details
    rates.each do |rate|
      lodging = Lodging.find_by(open_gds_property_id: rate[:property_id])
      room_types = lodging.room_types.includes(availabilities: %i[prices lodging rate_plan], rate_plans: :rule)
      rate_plans = []
      rules = []
      availabilities = []
      prices = []
      dates = if rate[:rate_enabled]
                (Date.today..365.days.from_now).map(&:to_s)
              else
                (rate[:valid_from].to_date..rate[:valid_till].to_date).map(&:to_s)
              end
      rate[:accommodations].each do |accommodation|
        room_type = room_types.find { |rt| rt[:open_gds_accommodation_id] == accommodation[:accom_id] }
        rate_plan = room_type.rate_plans.find { |rp| rp[:open_gds_rate_id] == rate[:rate_id] }
        rate_plan = room_type.rate_plans.new(open_gds_rate_id: rate[:rate_id]) unless rate_plan.present?
        rate_plan.rate_enabled = rate[:rate_enabled] if rate[:rate_enabled].present?
        rate_plan.open_gds_valid_permanent = rate[:valid_pernament] if rate[:valid_pernament].present?
        rate_plan.open_gds_res_fee = rate[:res_fee] if rate[:res_fee].present?
        rate_plan.open_gds_rate_type = rate[:rate_type] if rate[:rate_type].present?
        if rate_plan.new_record?
          rate_plan.created_at = DateTime.current
        elsif rate_plan.changed?
          rate_plan.updated_at = DateTime.current
        end
        rate_plans << rate_plan if rate_plan.new_record? || rate_plan.changed?

        params = {
          available: accommodation[:default_available],
          minlos: rate[:default_minlos],
          maxlos: rate[:default_maxlos],
          rate_plan_id: rate_plan.id
        }

        byebug
        dates.each do |date|
          availability = room_type.availabilities.find { |avail| avail[:available_on] == date.to_date && avail[:rate_plan_id] == rate_plan.id }
          availability = room_type.availabilities.new(available_on: date, rate_plan: rate_plan) unless availability.present?
          availability = set_availabilties params: params, availability: availability
          availabilities << availability
        end

        rule = rate_plan.rule.present? ? rate_plan.rule : rate_plan.build_rule
        rule.start_date = rate[:valid_from] if rate[:valid_from].present?
        rule.end_date = rate[:valid_till] if rate[:valid_till].present?
        rule.open_gds_restriction_type = rate[:restriction_type] if rate[:restriction_type].present?
        rule.open_gds_restriction_days = rate[:restriction_days] if rate[:restriction_days].present?
        rule.open_gds_arrival_days = rate[:arrival_days] if rate[:arrival_days].present?
        if rule.new_record?
          rule.created_at = DateTime.current
        elsif rule.changed?
          rule.updated_at = DateTime.current
        end
        rule.lodging_id = lodging.id
        rules << rule if rule.new_record? || rule.changed?

        params = {
          minlos: rate[:default_minlos],
          maxlos: rate[:default_maxlos],
          rate: accommodation[:default_rate],
          single_rate_type: accommodation[:default_single_rate_type],
          single_rate: accommodation[:default_single_rate],
          extra_night_rate: accommodation[:extra_night_rate]
        }

        availabilities.each do |availability|
          price = set_prices params: params, availability: availability
          prices << price if price.new_record? || price.changed?
        end
      end

      RatePlan.import rate_plans, batch_size: 150, on_duplicate_key_update: { columns: %i[rate_enabled open_gds_valid_permanent open_gds_res_fee open_gds_rate_type updated_at] } if rate_plans.present?
      byebug
      Availability.import availabilities.each {|availability| availability.rate_plan_id = availability.rate_plan.id }, batch_size: 150, on_duplicate_key_update: { columns: %i[available_on rr_booking_limit rr_minimum_stay rr_check_in_closed rr_check_out_closed updated_at] } if availabilities.present?
      Rule.import rules.each { |rule| rule.rate_plan_id = rule.rate_plan.id }, batch_size: 150, on_duplicate_key_update: { columns: %i[start_date end_date open_gds_restriction_type open_gds_restriction_days open_gds_arrival_days updated_at] } if rules.present?
      Price.import prices.each { |price| price.availability_id = price.availability.id }, batch_size: 150, on_duplicate_key_update: { columns: %i[amount minimum_stay open_gds_single_rate_type open_gds_single_rate open_gds_extra_night_rate adults children infants updated_at] } if prices.present?
      availabilities = []
      prices = []
      # rate[:accommodations].each do |accommodation|
      #   room_type = room_types.find { |rt| rt[:open_gds_accommodation_id] == accommodation[:accom_id] }
      #   rate_plan = room_type.rate_plans.find { |rp| rp[:open_gds_rate_id] == rate[:rate_id] }
      #   accommodation[:status]&.each do |accommodation_status|
      #     availability = room_type.availabilities.find do |avail|
      #       avail[:available_on] == accommodation_status[:date].to_date && avail[:rate_plan_id] == rate_plan.id
      #     end
      #
      #     params = {
      #       available: accommodation_status[:available],
      #       minlos: accommodation_status[:minlos],
      #       maxlos: accommodation_status[:maxlos],
      #       rate: accommodation_status[:daily_rate],
      #       single_rate: accommodation_status[:daily_single_rate],
      #       close_out: accommodation_status[:close_out],
      #       cta: accommodation_status[:cta],
      #       ctd: accommodation_status[:ctd],
      #       rate_plan_id: rate_plan.id
      #     }
      #
      #     availability = set_availabilties params: params, availability: availability
      #     price = set_prices params: params, availability: availability
      #     availabilities << availability if availability.new_record? || availability.changed?
      #     prices << price if price.new_record? || price.changed?
      #   end
      # end
      #
      # Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: %i[available_on rr_booking_limit rr_minimum_stay rr_check_in_closed rr_check_out_closed updated_at] } if availabilities.present?
      # Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: %i[amount minimum_stay open_gds_single_rate_type open_gds_single_rate open_gds_extra_night_rate adults children infants updated_at] } if prices.present?
    end
  end

  private

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
