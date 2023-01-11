class Api::V2::PagesController < Api::V2::ApiController
  def home
    render json: {
      popular_lodgings: Api::V2::CampaignSerializer.new(CustomText.popular.includes(:country, :region, :experience)).serializable_hash,
      campaigns: Api::V2::CampaignSerializer.new(CustomText.home_page.includes(:country, :region, :experience)).serializable_hash,
      locations: Api::V2::CountrySerializer.new(Country.enabled).serializable_hash,
      new_lodgings: Api::V2::LodgingSerializer.new(Lodging.new_lodgings).serializable_hash,
      reviews: Api::V2::ReviewSerializer.new(Review.last(10)).serializable_hash,
      information_pages: Page.not_private.includes(:translations),
      lodging_types: Lodging.lodging_types.keys
    }, status: :ok
  end
end
