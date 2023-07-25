class Crm::V1::AmenitySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :filter_enabled, :hot, :icon,  :name_nl, :name_en, :slug, :slug_en, :slug_nl, :amenity_category_id

  attributes :amenity_category do |amenity|
    amenity.amenity_category.try(:name)
  end
end
