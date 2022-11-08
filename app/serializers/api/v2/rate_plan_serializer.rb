class Api::V2::RatePlanSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :code, :name, :description, :min_occupancy, :max_occupancy

  attribute :expired do |rate_plan|
    rate_plan.expired?
  end
end
