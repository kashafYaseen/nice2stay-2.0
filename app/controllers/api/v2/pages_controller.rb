class Api::V2::PagesController < Api::V2::ApiController
  def home
    render json: {
      accommodation_type_campagins: Api::V2::CampaignSerializer.new(Campaign.accommodation_type).serializable_hash,
      collection_campaigns: Api::V2::CampaignSerializer.new(Campaign.collection).serializable_hash,
      footer_campaigns: Api::V2::CampaignSerializer.new(Campaign.footer).serializable_hash,
      top_menu_campaigns: Api::V2::CampaignSerializer.new(Campaign.top_menu).serializable_hash,
      locations: Api::V2::CountrySerializer.new(Country.enabled).serializable_hash,
      new_lodgings: Api::V2::LodgingSerializer.new(Lodging.new_lodgings).serializable_hash,
      reviews: Api::V2::ReviewSerializer.new(Review.last(10)).serializable_hash,
      lodging_types: Lodging.lodging_types.keys
    }, status: :ok
  end
end
