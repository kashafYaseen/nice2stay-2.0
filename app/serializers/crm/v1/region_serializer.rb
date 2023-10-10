class Crm::V1::RegionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :name_en, :name_nl, :slug_en, :slug_nl, :title_en, :title_nl, :content, :content_en, :content_nl,
              :meta_title_en, :meta_title_nl, :published, :short_desc, :country_id, :villas_desc,
              :apartment_desc, :bb_desc

  attributes :region_country do |region|
    region.country.try(:name_en)
  end

end
