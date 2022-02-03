class Api::V2::PlaceCategorySerializer
  include FastJsonapi::ObjectSerializer
  attributes  :id, :created_at, :updated_at, :color_code, :name, :slug
end
