class Crm::V1::OwnerCommissionsSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :business_name, :commission_current_year, :commission_previous_7_year, :commission_previous_6_year,
              :commission_previous_5_year, :commission_previous_4_year, :commission_previous_3_year,
              :commission_previous_2_year, :commission_previous_1_year, :commission_next_1_year

  attributes :country_name do |owner|
    owner.country.try(:name)
  end

  attributes :region_name do |owner|
    owner.region.try(:name)
  end
end
