class Crm::V1::CampaignSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :title, :collection, :popular_search,
            :footer, :top_menu, :homepage, :popular_homepage, :country_id, :region_id, :title_en, :title_nl,
            :description_nl, :description_en, :description, :to, :from, :max_price, :min_price, :category, :url

  attributes :region_name do |campaign|
    campaign.get_region(campaign.region_id).try(:name)
  end

  attributes :country_name do |campaign|
    campaign.get_country(campaign.country_id).try(:name)
  end
end
