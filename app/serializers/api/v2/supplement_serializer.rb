class Api::V2::SupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :description, :type, :rate_type, :rate, :child_rate, :maximum_number

  attributes :options do |supplement, params|
    supplement.options(params[:guests])
  end
end
