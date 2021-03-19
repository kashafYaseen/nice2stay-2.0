class UpdateLodgingRatePlans
  attr_reader :lodging,
              :rate_plans

  def self.call(lodging:, rate_plans:)
    new(lodging: lodging, rate_plans: rate_plans).call
  end

  def initialize(lodging:, rate_plans:)
    @lodging = lodging
    @rate_plans = rate_plans
  end

  def call
    return unless rate_plans.present?

    update_rate_plans
  end

  private
    def update_rate_plans
      existing_rate_plans = lodging.rate_plans
      new_rate_plans = []
      rate_plans.each do |rp|
        rate_plan = existing_rate_plans.find { |erp| erp.code == rp[:code] } || lodging.rate_plans.new(created_at: DateTime.current, updated_at: DateTime.current)
        rate_plan.code = rp[:code]
        rate_plan.name = rp[:name]
        rate_plan.description = rp[:description]
        rate_plan.open_gds_rate_id = rp[:open_gds_rate_id]
        new_rate_plans << rate_plan if rate_plan.new_record? || rate_plan.changed?
      end

      return unless new_rate_plans.present?

      RatePlan.import new_rate_plans, batch_size: 150, on_duplicate_key_update: { columns: RatePlan.column_names - %w[id updated_at] }
    end
end
