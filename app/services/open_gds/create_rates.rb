class OpenGds::CreateRates
  attr_reader :body

  def initialize(body)
    @body = body
  end

  def self.call(body)
    self.new(body).call
  end

  def call
    rate = body.first
    room_types = Lodging.find_by(open_gds_property_id: rate[:property_id]).room_types.includes(availabilities: :prices, rate_plans: :rule)
    rate_plans, rules, availabilities, prices = [], [], [], []
    rate[:accommodations].each do |accommodation|
      room_type = room_types.find { |room_type| room_type[:open_gds_accommodation_id] == accommodation[:accom_id] }
      rate_plan = room_type.rate_plans.find { |rate_plan| rate_plan[:open_gds_rate_id] == rate[:rate_id] }
      rate_plan = room_type.rate_plans.new(open_gds_rate_id: rate[:rate_id]) unless rate_plan.present?
      rate_plan.rate_enabled = rate[:rate_enabled] if rate[:rate_enabled].present?
      rate_plan.open_gds_valid_permanent = rate[:valid_pernament] if rate[:valid_pernament].present?
      rate_plan.open_gds_res_fee = rate[:res_fee] if rate[:res_fee].present?
      rate_plan.open_gds_rate_type = rate[:rate_type] if rate[:rate_type].present?
      rate_plan.updated_at = DateTime.current unless rate_plan.new_record?

      rule = rate_plan.rule.present? ? rate_plan.rule : rate_plan.build_rule
      rule.start_date = rate[:valid_from] if rate[:valid_from].present?
      rule.end_date = rate[:valid_till] if rate[:valid_till].present?
      rule.open_gds_restriction_type = rate[:restriction_type] if rate[:restriction_type].present?
      rule.open_gds_restriction_days = rate[:restriction_days] if rate[:restriction_days].present?
      rule.open_gds_arrival_days = rate[:arrival_days] if rate[:arrival_days].present?
      rule.updated_at = DateTime.current unless rule.new_record?

      (rate[:valid_from].to_date..rate[:valid_till].to_date).map(&:to_s).each do |date|
        availability = room_type.availabilities.find { |availability| availability[:available_on] == date.to_date && availability[:rate_plan_id] == rate_plan.id } unless rate_plan.new_record?
        availability = room_type.availabilities.new(available_on: date, rate_plan: rate_plan) unless availability.present?
        params = {
          available: accommodation[:default_available],
          minlos: rate[:default_minlos],
          maxlos: rate[:default_maxlos],
          rate: accommodation[:default_rate],
          single_rate_type: accommodation[:default_single_rate_type],
          single_rate: accommodation[:default_single_rate],
          extra_night_rate: accommodation[:extra_night_rate]
        }

        availability, price = set_availabilties_and_prices params: params, availability: availability
        availabilities << availability if availability.new_record? || availability.changed?
        prices << price if price.new_record? || price.changed?
      end

      accommodation[:status]&.each do |accommodation_status|
        availability = room_type.availabilities.find { |availability| availability[:available_on] == date.to_date && availability[:rate_plan_id] == rate_plan.id } unless rate_plan.new_record?
        availability = availabilities.find { |availability| availability[:available_on] == accommodation_status[:date].to_date && availability[:rate_plan_id] == rate_plan.id } unless rate_plan.new_record?
        params = {
          available: accommodation_status[:available],
          minlos: accommodation_status[:minlos],
          maxlos: accommodation_status[:maxlos],
          rate: accommodation_status[:daily_rate],
          single_rate: accommodation_status[:daily_single_rate],
          close_out: accommodation_status[:close_out],
          cta: accommodation_status[:cta],
          ctd: accommodation_status[:ctd]
        }

        availability, price = set_availabilties_and_prices params: params, availability: availability
        availabilities << availability if availability.new_record? || availability.changed?
        prices << price if price.new_record? || price.changed?
      end

      rate_plans << rate_plan if rate_plan.new_record? || rate_plan.changed?
      rules << rule if rule.new_record? || rule.changed?
    end

    RatePlan.import rate_plans, batch_size: 150, on_duplicate_key_update: { columns: [:rate_enabled, :open_gds_valid_permanent, :open_gds_res_fee, :open_gds_rate_type, :updated_at] } if rate_plans.present?
    Rule.import rules, batch_size: 150, on_duplicate_key_update: { columns: [:start_date, :end_date, :open_gds_restriction_type, :open_gds_restriction_days, :open_gds_arrival_days, :updated_at] } if rules.present?
    Availability.import availabilities, batch_size: 150, on_duplicate_key_update: { columns: [:available_on, :rr_booking_limit, :rr_minimum_stay, :rr_check_in_closed, :rr_check_out_closed, :updated_at] } if availabilities.present?
    Price.import prices, batch_size: 150, on_duplicate_key_update: { columns: [:amount, :minimum_stay, :open_gds_single_rate_type, :open_gds_single_rate, :open_gds_extra_night_rate, :adults, :children, :infants, :updated_at] } if prices.present?
  end

  private
    def set_availabilties_and_prices(params:, availability:)
      if params[:close_out]
        availability.rr_booking_limit = 0
      else
        availability.rr_booking_limit = params[:available] if params[:available].present?
      end

      stays = []
      stays << params[:minlos] if params[:minlos].present?
      stays << params[:maxlos] if params[:maxlos].present?
      availability.rr_minimum_stay = (stays[0]..stays[-1]).map(&:to_s) if stays.present?
      availability.rr_check_in_closed = params[:cta] if params[:cta].present?
      availability.rr_check_out_closed = params[:ctd] if params[:ctd].present?
      availability.updated_at = DateTime.current unless availability.new_record?
      price = availability.prices.find { |price| price[:adults] == [999] && price[:children] == [999] && price[:infants] == [999] }
      price = availability.prices.new(adults: [999], children: [999], infants: [999]) unless price.present?
      price.amount = params[:rate] if params[:rate].present?
      price.minimum_stay = (stays[0]..stays[-1]).map(&:to_s) if stays.present?
      price.open_gds_single_rate_type = params[:single_rate_type] if params[:single_rate_type].present?
      price.open_gds_single_rate = params[:single_rate] if params[:single_rate].present?
      price.open_gds_extra_night_rate = params[:extra_night_rate] if params[:extra_night_rate].present?
      price.updated_at = DateTime.current unless price.new_record?
      return availability, price
    end
end
