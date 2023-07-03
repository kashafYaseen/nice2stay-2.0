class Crm::V1::CampaignSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :title, :url, :collection, :popular_search,
            :footer, :top_menu, :homepage, :popular_homepage

  attributes :region_name do |campaign|
    campaign.get_region(campaign.region_id).try(:name)
  end

  attributes :country_name do |campaign|
    campaign.get_country(campaign.country_id).try(:name)
  end
end
