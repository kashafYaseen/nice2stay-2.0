class SaveAmenityDetails
  attr_reader :params
  attr_reader :amenity

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @amenity = Amenity.find_or_initialize_by(crm_id: amenity_params[:crm_id])
  end

  def call
    save_amenity
    save_lodgings
    update_translations
    update_category_translations(amenity.amenity_category)
    amenity
  end

  private
    def save_amenity
      amenity.attributes = amenity_params
      amenity.amenity_category = amenity_category
      amenity.save
    end

    def save_lodgings
      lodgings = Lodging.where(slug: params[:lodgings])
      amenity.lodgings = lodgings
    end

    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = amenity.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def update_category_translations category
      return unless params[:category_translations].present? && category.present?
      params[:category_translations].each do |translation|
        _translation = category.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = category_translation_params(translation)
        _translation.save
      end
    end

    def amenity_category
      category = AmenityCategory.find_or_initialize_by(crm_id: category_params[:crm_id])
      category.attributes = category_params
      category.save
      category
    end

    def amenity_params
      params.require(:amenity).permit(
        :slug,
        :name,
        :crm_id,
        :filter_enabled,
        :hot,
        :icon,
        :parent,
        :image
      )
    end

    def translation_params(translation)
      translation.permit(
        :slug,
        :name,
        :locale,
      )
    end

    def category_params
      params.require(:category).permit(
        :name,
        :crm_id,
      )
    end

    def category_translation_params(translation)
      translation.permit(
        :name,
        :locale,
      )
    end
end

