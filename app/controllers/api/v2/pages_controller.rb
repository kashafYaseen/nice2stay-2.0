class Api::V2::PagesController < Api::V2::ApiController
  before_action :set_page, only: [:show]

  def home
    render json: {
      locations: Api::V2::CountrySerializer.new(Country.enabled).serializable_hash,
      new_lodgings: Api::V2::LodgingSerializer.new(Lodging.new_lodgings).serializable_hash,
      reviews: Api::V2::ReviewSerializer.new(Review.perfect.desc.last(10)).serializable_hash,
      information_pages: Page.not_private.includes(:translations),
      lodging_types: Lodging.lodging_types.keys
    }, status: :ok
  end

  def custom_texts
    render json: {
      custom_texts: GetCustomTextData.call(locale),
    }, status: :ok
  end

  def campaigns
    render json: {
      footer_accommodation_types: GetCampaigsData.call('popular_search', 'footer', locale),
      footer_collections: GetCampaigsData.call('collection', 'footer', locale),
      homepage_accommodation_types: GetCampaigsData.call('popular_search', 'homepage', locale),
      homepage_collections: GetCampaigsData.call('collection', 'homepage', locale),
      topmenu_accommodation_types: GetCampaigsData.call('popular_search', 'top_menu', locale),
      topmenu_collections: GetCampaigsData.call('collection', 'top_menu', locale),
    }, status: :ok
  end

  def reviews
    @reviews = Review.published.desc
    reviews_pagy, pagy_reviews = pagy(@reviews, items: params[:per_page], page: params[:page])
    render json: Api::V2::ReviewSerializer.new(pagy_reviews).serializable_hash.merge(total_reviews: @reviews.count), status: :ok
  end

  def show
    render json: Api::V2::PageSerializer.new(@page).serializable_hash, status: :ok
  end

  private
    def set_page
      @page = Page.not_private.find_by(id: params[:id])
    end
end
