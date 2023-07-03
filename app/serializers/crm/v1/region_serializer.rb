class Crm::V1::RegionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :content

  attributes :region_country do |region|
    region.country.try(:name)
  end
end
