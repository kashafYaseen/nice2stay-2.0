class Api::V2::CategorySerializer
  include FastJsonapi::ObjectSerializer
  attributes  :id, :created_at, :updated_at, :color_code, :name, :slug
end
