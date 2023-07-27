class Crm::V1::AdminUser::CampaignsController < Crm::V1::ApiController
  before_action :authenticate
  before_action :get_campaign, only: %i[edit update destroy]

  def index
    render json: Crm::V1::CampaignSerializer.new(Campaign.all).serialized_json, status: :ok
  end

  def new
  end

  def create
    @campaign = Campaign.new(campaign_params)
    @campaign.category = params[:campaign][:category]
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
    @campaign.category = params[:campaign][:category]
    @campaign.publish = params[:campaign][:publish] if params[:campaign][:publish].blank?
    if @campaign.update(campaign_params)
      @campaign.region_ids = params[:campaign][:region_ids]
      set_image_sequence if !params[:sequence].blank?
    else
      render :edit
    end
  end

  def destroy
    @campaign.destroy
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

    def get_campaign
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
        {:publish => []},
        :category,
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
