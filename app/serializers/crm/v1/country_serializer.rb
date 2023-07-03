class Crm::V1::CountrySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :slug, :title, :content, :image, :disable, :meta_title,
            :villas_desc, :apartment_desc, :bb_desc, :dropdown, :sidebar
end
