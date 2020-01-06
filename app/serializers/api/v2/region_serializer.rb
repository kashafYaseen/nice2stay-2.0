class Api::V2::RegionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :title, :content, :image, :country_id
end
