class Api::V2::SupplementSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :description, :rate_type, :rate, :child_rate, :maximum_number

  attributes :elements do |supplement, params|
    supplement.elements(params[:adults].to_i, params[:children].to_i)
  end

  attribute :calculated_data do |supplement, params|
    supplement.cumulative_price(params)
  end
end
