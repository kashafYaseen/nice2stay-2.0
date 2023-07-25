class Crm::V1::AdminUser::CountriesController < Crm::V1::ApiController

  before_action :set_country, only: %i[edit update destroy]

  def index

    @q = Country.ransack(translations_name_cont: params[:query])
    @pagy, @records = pagy(@q.result(distinct: true), items: params[:items], page: params[:page], items: params[:per_page])

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

  def regions_by_country
    country = Country.find(params[:id])
    regions = country.regions
    render json: regions
  end

  private

    def set_country
      @country = Country.find(params[:id])
    end

    def country_params
      params.require(:country).permit(
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
