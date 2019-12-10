class Api::V2::AmenitySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :filter_enabled, :hot, :icon
end
