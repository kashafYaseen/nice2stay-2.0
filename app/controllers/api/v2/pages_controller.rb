class Api::V2::PagesController < Api::V2::ApiController
  def home
    render json: {
      accommodation_type_campagins: GetCampaigsData.call('accommodation_type', locale),
      collection_campaigns: GetCampaigsData.call('collection', locale),
      footer_campaigns: GetCampaigsData.call('footer', locale),
      top_menu_campaigns:  GetCampaigsData.call('top_menu', locale),
      locations: Api::V2::CountrySerializer.new(Country.enabled).serializable_hash,
      new_lodgings: Api::V2::LodgingSerializer.new(Lodging.new_lodgings).serializable_hash,
      reviews: Api::V2::ReviewSerializer.new(Review.last(10)).serializable_hash,
      information_pages: Page.not_private.includes(:translations),
      lodging_types: Lodging.lodging_types.keys
    }, status: :ok
  end
end
