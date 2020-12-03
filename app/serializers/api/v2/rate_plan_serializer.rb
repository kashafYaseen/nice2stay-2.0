class Api::V2::RatePlanSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :code, :name, :price, :calculated_price, :dynamic_price, :price_valid, :price_errors
end
