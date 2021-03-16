class Api::V2::RatePlanSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :code, :name, :description
end
