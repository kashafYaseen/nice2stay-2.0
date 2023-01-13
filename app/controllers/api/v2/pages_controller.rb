class Api::V2::PagesController < Api::V2::ApiController
  before_action :set_page, only: [:show]

  def home
    render json: {
      accommodation_type_campagins: GetCampaigsData.call('accommodation_type', locale),
      collection_campaigns: GetCampaigsData.call('collection', locale),
      footer_campaigns: GetCampaigsData.call('footer', locale),
      top_menu_campaigns:  GetCampaigsData.call('top_menu', locale),
      locations: Api::V2::CountrySerializer.new(Country.enabled).serializable_hash,
      new_lodgings: Api::V2::LodgingSerializer.new(Lodging.new_lodgings).serializable_hash,
      reviews: Api::V2::ReviewSerializer.new(Review.perfect.last(10)).serializable_hash,
      information_pages: Page.not_private.includes(:translations),
      lodging_types: Lodging.lodging_types.keys
    }, status: :ok
  end

  def reviews
    reviews_pagy, reviews = pagy(Review.published, items: params[:per_page], page: params[:page])
    render json: Api::V2::ReviewSerializer.new(reviews).serializable_hash, status: :ok
  end

  def show
    render json: Api::V2::PageSerializer.new(@page).serializable_hash, status: :ok
  end

  private
    def set_page
      @page = Page.not_private.find_by(id: params[:id])
    end
end
