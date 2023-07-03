class Crm::V1::DiscountSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :start_date, :end_date, :description, :publish, :discount_type,
              :valid_to, :value, :minimum_days

  attributes :lodging_name do |discount|
    discount.lodging.try(:name)
  end
end
