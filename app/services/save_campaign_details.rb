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
    update_translations
    campaign
  end

  private
    def save_campaign
      campaign.attributes = campaign_params.merge(category: params.dig(:campaign, :category).permit(params.dig(:campaign, :category).keys).to_h )
      campaign.save
      campaign.reindex
    end

    def save_regions
      return unless params[:regions].present?
      params[:regions].each do |region_params|
        region = Region.find_or_create_region(region_params[:country_name], region_params[:region_name])
        region.reindex
        campaign.regions << region unless campaign.regions.find_by(id: region.id).present?
      end
    end

    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = campaign.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def lodging
      Lodging.find_by(slug: params[:reservation][:lodging_slug])
    end

    def campaign_params
      params.require(:campaign).permit(
        :title,
        :description,
        :region_id,
        :country_id,
        :from,
        :to,
        :min_price,
        :max_price,
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
        :crm_urls,
        :created_at,
        :updated_at,
        { images: [] },
        { publish: [] },
        { thumbnails: [] },
      )
    end

    def translation_params(translation)
      translation.permit(
        :url,
        :crm_urls,
        :locale,
        :title,
        :description,
      )
    end

end
