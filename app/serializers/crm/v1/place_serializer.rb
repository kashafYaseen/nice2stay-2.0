class Crm::V1::PlaceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :address, :description, :latitude, :longitude, :spotlight, :slug, :header_dropdown, :publish, :short_desc, :short_desc_nav ,:name_nl, :name_en, :description_en, :description_nl, :slug_en, :slug_nl, :details

  attributes :place_category do |place|
    place.place_category.try(:name)
  end

  attributes :place_category_id do |place|
    place.place_category.try(:id)
  end

  attributes :place_region do |place|
    place.region.try(:name)
  end

  attributes :place_region_id do |place|
    place.region.try(:id)
  end

  attributes :place_country do |place|
    place.country.try(:name)
  end

  attributes :place_country_id do |place|
    place.country.try(:id)
  end
end
