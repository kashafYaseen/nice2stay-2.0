class Api::V2::PagesController < Api::V2::ApiController
  def home
    render json: {
      popular_lodgings: Api::V2::LodgingSerializer.new(Lodging.home_page).serializable_hash,
      campaigns: Api::V2::CampaignSerializer.new(CustomText.home_page.popular.includes(:country, :region, :experience)).serializable_hash,
      locations: Api::V2::CountrySerializer(Country.enabled).serializable_hash,
    }, status: :ok
  end
end
