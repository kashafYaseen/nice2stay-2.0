class Api::V2::CancellationPoliciesSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :cancellation_percentage, :days_prior_to_check_in, :rate_plan_id
end
