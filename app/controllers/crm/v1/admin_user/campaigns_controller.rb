class Crm::V1::AdminUser::CampaignsController < Crm::V1::AdminUser::ApiController
  before_action :authenticate
  before_action :set_campaign, only: %i[edit update destroy]

  def index
    @q = Campaign.ransack(translations_title_cont: params[:query])
    @pagy, @records = pagy(@q.result(distinct: true), items: params[:items], page: params[:page], items: params[:per_page])

    render json: Crm::V1::CampaignSerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok
  end

  def new
    render json: { countries: Crm::V1::CountrySerializer.new(Country.all).serializable_hash }, status: :ok
  end

  def create
    @campaign = Campaign.new(campaign_params)
    if @campaign.save
      @campaign.region_ids = params[:campaign][:region_ids]
      set_image_sequence if !params[:sequence].blank?
      render json: Crm::V1::CampaignSerializer.new(@campaign).serialized_json, status: :ok
    else
      unprocessable_entity(@campaign.errors)
    end
  end

  def edit
  end

  def update
    @campaign.publish = params[:campaign][:publish] if params[:campaign][:publish].blank?
    if @campaign.update(campaign_params)
      @campaign.region_ids = params[:campaign][:region_ids]
      set_image_sequence if !params[:sequence].blank?
      render json: Crm::V1::CampaignSerializer.new(@campaign).serialized_json, status: :ok
    else
      unprocessable_entity(@campaign.errors)
    end
  end

  def destroy
    @campaign.destroy
  end

  def options_from_category
    if (params[:category_id] == '0')
      render json: { experiences: Crm::V1::ExperienceSerializer.new(Experience.all).serializable_hash }, status: :ok
    elsif (params[:category_id] == '1')
      render json: { lodging_categories: Crm::V1::LodgingCategorySerializer.new(LodgingCategory.all).serializable_hash }, status: :ok
    elsif (params[:category_id] == '2')
      render json: { guests: (1..30).to_a }, status: :ok
    elsif (params[:category_id] == '3')
      render json: { amenities: Crm::V1::AmenitySerializer.new(Amenity.all).serializable_hash }, status: :ok
    else
      render json: [], status: :ok
    end
  end

  # def more_category
  #   @parent_id = Time.now.to_i
  # end

  # def select_category
  #   @parent_id = params[:parent_id]
  #   @category = params[:category]
  #   @categories_count = params[:categories_count]
  # end

  # def capaign_data
  # end

  private

    def set_campaign
      @campaign = Campaign.find_by(id: params[:id])
    end

    def campaign_params
      params.require(:campaign).permit(
        :title_nl,
        :title_en,
        :country_id,
        :spotlight,
        :region_id,
        :description_nl,
        :description_en,
        :slider_desc,
        { publish: [] },
        { category: {} },
        :price, #here this is price attribute nd in crm schema it is price_range
        :url,  #here this is url attribute nd in crm schema it is redirect_url
        :slider,
        :from,
        :to,
        :popular_search,
        :popular_homepage,
        :article_spotlight,
        :collection,
        :footer,
        :top_menu,
        :homepage,
        :crm_urls, #here it is crm_urls and in crm schema it is urls
        :min_price,
        :max_price,
        # :meta_title,
        # :meta_description,
        # :experience_id,
        # :locale,
        # :label,
      )
    end

    #save image
    def set_image_sequence
      params[:sequence].each_with_index do |id,index|
        @image = Image.find(id)
        @image.sequence = index unless @image.sequence.to_i == index
        @image.imagable_id = @campaign.id unless @image.imagable_id
        @image.imagable_type = @campaign.class.to_s unless @image.imagable_type
        @image.save!
      end
    end
end
