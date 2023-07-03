class Crm::V1::AmenitySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :filter_enabled, :hot, :icon

  attributes :amenity_category do |amenity|
    amenity.amenity_category.try(:name)
  end
end
