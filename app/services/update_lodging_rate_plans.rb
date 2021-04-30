class UpdateLodgingRatePlans
  attr_reader :lodging,
              :parent_rate_plans,
              :room_rates

  def self.call(lodging:, parent_rate_plans:, room_rates:)
    new(lodging: lodging, parent_rate_plans: parent_rate_plans, room_rates: room_rates).call
  end

  def initialize(lodging:, parent_rate_plans:, room_rates:)
    @lodging = lodging
    @parent_rate_plans = parent_rate_plans
    @room_rates = room_rates
  end

  def call
    return if parent_rate_plans.blank? && room_rates.blank?
    return update_parent_rate_plans if lodging.as_parent?

    update_room_rate_plans if lodging.as_child? && lodging.room_raccoon?
  end

  private
    def update_parent_rate_plans
      existing_rate_plans = lodging.rate_plans
      new_rate_plans = []
      parent_rate_plans.each do |rp|
        rate_plan = existing_rate_plans.find { |erp| erp.crm_id == rp[:crm_id] } || lodging.rate_plans.new(created_at: DateTime.current, updated_at: DateTime.current, crm_id: rp[:crm_id])
        rate_plan.name = rp[:name]
        rate_plan.description = rp[:description]
        rate_plan.open_gds_rate_id = rp[:open_gds_rate_id]
        new_rate_plans << rate_plan if rate_plan.new_record? || rate_plan.changed?
      end

      return unless new_rate_plans.present?

      RatePlan.import new_rate_plans, batch_size: 150, on_duplicate_key_update: { columns: RatePlan.column_names - %w[id updated_at] }
    end

    def update_room_rate_plans
      existing_room_rates = lodging.room_rates.includes(:rate_plan)
      rate_plans = lodging.room_rate_plans
      new_room_rates = []
      room_rates.each do |room_rate_params|
        room_rate = existing_room_rates.find { |rr| rr.rate_plan_crm_id == room_rate_params[:rate_plan_crm_id] }
        if room_rate.blank?
          rate_plan = rate_plans.find { |rp| rp.crm_id == room_rate_params[:rate_plan_crm_id] }
          room_rate = lodging.room_rates.new(created_at: DateTime.current, updated_at: DateTime.current, rate_plan_id: rate_plan.id) if rate_plan.present?
        end

        if room_rate.present?
          room_rate.default_rate = lodging.price if lodging.price.present?
          new_room_rates << room_rate if room_rate.new_record? || room_rate.changed?
        end
      end

      return unless new_room_rates.present?

      RoomRate.import new_room_rates, batch_size: 150, on_duplicate_key_update: { columns: RoomRate.column_names - %w[id updated_at] }
    end
end
