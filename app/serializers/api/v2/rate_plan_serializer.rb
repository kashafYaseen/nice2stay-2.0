class Api::V2::RatePlanSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :code, :name, :description, :min_occupancy, :max_occupancy, :pre_payment_percentage, :pre_payment_hours_limit, :final_payment_days_limit

  attribute :expired do |rate_plan|
    rate_plan.expired?
  end

  attribute :cancellation_policies do |rate_plan|
    Api::V2::CancellationPoliciesSerializer.new(rate_plan.cancellation_policies)
  end
end
