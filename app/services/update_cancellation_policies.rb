class UpdateCancellationPolicies
  attr_reader :params,

  def self.call(params:)
    new(params: params).call
  end

  def initialize(params:)
    @params = params
  end

  def call
    update_cancellation_policies
  end

  private
    def update_cancellation_policies
      params.each do |_cancellation|
        rate_plan = RatePlan.find_by(crm_id: _cancellation[:rate_plan_id])
        cancellation_policy = CancellationPolicy.find_or_initialize_by(crm_id: _cancellation[:crm_id])
        cancellation_policy.attributes = cancellation_policy_params(_cancellation).merge(rate_plan_id: rate_plan&.id)
        cancellation_policy.save
      end
    end

    def cancellation_policy_params(params)
      params.permit(:cancellation_percentage, :days_prior_to_check_in, :crm_id)
    end
end
