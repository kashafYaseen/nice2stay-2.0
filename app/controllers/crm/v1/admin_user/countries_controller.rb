class Crm::V1::AdminUser::CountriesController < Crm::V1::AdminUser::ApiController
  before_action :authenticate
  before_action :set_country, only: %i[edit update destroy regions]

  def index
    @q = ransack_search_translated(Country, :translations_name, query: params[:query])
    @pagy, @records = pagy(@q.result, items: params[:items], page: params[:page], items: params[:per_page])

    render json: Crm::V1::CountrySerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok
  end

  def new

  end

  def edit
  end

  def create
    country = Country.new(country_params)
    if country.save
      render json: Crm::V1::CountrySerializer.new(country).serialized_json, status: :ok
    else
      unprocessable_entity(country.errors)
    end
  end

  def update
    if @country.update(country_params)
      render json: Crm::V1::CountrySerializer.new(@country).serialized_json, status: :ok
    else
      unprocessable_entity(@country.errors)
    end
  end

  def destroy
    @country.destroy
    render json: { removed: @country.destroyed? }, status: :ok
  end

  def regions
    render json: Crm::V1::RegionSerializer.new(@country.regions).serializable_hash, status: :ok
  end

  private

    def set_country
      @country = Country.find(params[:id])
    end

    def country_params
      params.require(:country).permit(
        :name,
        :name_en,
        :name_nl,
        :slug_en,
        :slug_nl,
        :content_en,
        :content_nl,
        :title_en,
        :title_nl,
        :meta_title_en,
        :meta_title_nl,
        :disable,
        # :meta_description, #this attribute is additional
        :villas_desc,
        :apartment_desc,
        :bb_desc,
        :dropdown,
        :sidebar,
        # videos_attributes: [:id, :url, :start, :stop, :_destroy], #this attribute is additional
        # images_attributes: [:image, :id, :_destroy],
      )
    end
end
