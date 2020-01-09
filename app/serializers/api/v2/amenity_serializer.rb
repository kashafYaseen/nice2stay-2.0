class Api::V2::AmenitySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :filter_enabled, :hot, :icon, :amenity_category_name
end
