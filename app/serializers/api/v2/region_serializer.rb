class Api::V2::RegionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :title, :content, :image, :country_id

  attribute :lodging_count do |region|
    region.lodgings_published_parents_count
  end
end
