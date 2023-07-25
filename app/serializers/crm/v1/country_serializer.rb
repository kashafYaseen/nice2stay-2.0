class Crm::V1::CountrySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :name_en, :name_nl, :slug_en, :slug_nl, :title_en, :title_nl, :content_en, :content_nl, :image, :disable, :meta_title_en,
            :meta_title_nl, :villas_desc, :apartment_desc, :bb_desc, :dropdown, :sidebar
end
