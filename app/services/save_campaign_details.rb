class SaveCampaignDetails
  attr_reader :params
  attr_reader :campaign

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @campaign = Campaign.find_or_initialize_by(slug: campaign_params[:slug])
  end

  def call
    save_campaign
    save_regions
    campaign
  end

  private
    def save_campaign
      campaign.attributes = campaign_params
      campaign.save
    end

    def save_regions
      return unless params[:regions].present?
      params[:regions].each do |region_params|
        region = Region.find_or_create_region(region_params[:country_name], region_params[:region_name])
        campaign.regions << region unless campaign.regions.find_by(id: region.id).present?
      end
    end

    def lodging
      Lodging.find_by(slug: params[:reservation][:lodging_slug])
    end

    def campaign_params
      params.require(:campaign).permit(
        :title,
        :description,
        :slug,
        :url,
        :price,
        :slider,
        :slider_desc,
        :spotlight,
        :article_spotlight,
        :popular_search,
        :popular_homepage,
        :collection,
        { images: [] },
        { publish: [] },
      )
    end
end
