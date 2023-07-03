class Crm::V1::AdminUser::RegionsController < Crm::V1::ApiController

  before_action :get_region, only: [:edit, :update, :destroy]

  def index
    render json: Crm::V1::RegionSerializer.new(Region.all).serialized_json, status: :ok
  end

  def new
  end

  def edit
  end

  def create
    @region = Region.new(region_params)
    if @region.save
      render json: Crm::V1::RegionSerializer.new(@region).serialized_json, status: :ok
    else
      unprocessable_entity(@region.errors)
    end
  end

  def update
    if @region.update(region_params)
      render json: Crm::V1::RegionSerializer.new(@region).serialized_json, status: :ok
    else
      unprocessable_entity(@region.errors)
    end
  end

  def destroy
    @region.destroy
    render json: { removed: @region.destroyed? }, status: :ok
  end

  private

    def get_region
      @region = Region.friendly.find(params[:id])
    end

    def region_params
      params.require(:region).permit(
        :name_en,
        :name_nl,
        :slug_en,
        :slug_nl,
        :title_en,
        :title_nl,
        :meta_title_en,
        :meta_title_nl,
        :content_en,
        :content_nl,
        :published,
        :short_desc,
        :country_id,
        # :meta_description,
        :villas_desc,
        :apartment_desc,
        :bb_desc,
        # videos_attributes: [:id, :url, :start, :stop, :_destroy],
        images_attributes: [:image, :id, :_destroy],
      )
    end
end