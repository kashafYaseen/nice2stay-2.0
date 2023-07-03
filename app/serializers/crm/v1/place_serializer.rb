class Crm::V1::PlaceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :address, :description

  attributes :place_category do |place|
    place.place_category.try(:name)
  end

  attributes :place_region do |place|
    place.region.try(:name)
  end

  attributes :place_country do |place|
    place.country.try(:name)
  end
end
