class Api::V2::CountrySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :title, :content, :image, :disable
end
