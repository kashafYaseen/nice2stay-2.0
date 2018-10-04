class SaveCountryDetails
  attr_reader :params
  attr_reader :country

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @country = Country.find_or_initialize_by(slug: country_params[:slug])
  end

  def call
    save_country
    save_regions
    update_translations
    country
  end

  private
    def save_country
      country.attributes = country_params
      country.save
    end

    def save_regions
      return unless params[:regions].present?
      params[:regions].each do |region|
        _region = country.regions.find_or_initialize_by(slug: region[:slug])
        _region.attributes = region_params(region)
        _region.save
        update_region_translations(_region, region)
      end
    end

    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = country.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def update_region_translations(region, region_params)
      return unless region_params[:translations].present?
      region_params[:translations].each do |translation|
        _translation = region.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def country_params
      params.require(:country).permit(
        :name,
        :content,
        :disable,
        :slug,
        :title,
        :meta_title,
        :villas_desc,
        :apartment_desc,
        :bb_desc,
        :dropdown,
        :sidebar,
        :created_at,
        :updated_at,
        { thumbnails: [] },
        { images: [] },
      )
    end

    def translation_params(translation)
      translation.permit(
        :content,
        :name,
        :slug,
        :title,
        :meta_title,
        :locale,
      )
    end

    def region_params(region)
      region.permit(
        :name,
        :content,
        :slug,
        :title,
        :meta_title,
        :villas_desc,
        :apartment_desc,
        :bb_desc,
        :short_desc,
        :created_at,
        :updated_at,
        { images: [] },
        { thumbnails: [] },
      )
    end
end
