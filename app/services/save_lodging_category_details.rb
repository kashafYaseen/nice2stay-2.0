class SaveLodgingCategoryDetails
  attr_reader :params
  attr_reader :category
  
  def self.call(params)
    self.new(params).call
  end
  
  def initialize(params)
    @params = params
    @category = LodgingCategory.find_by(crm_id: category_params[:crm_id]) || LodgingCategory.friendly.find(category_params[:slug]) rescue LodgingCategory.new
  end
  
  def call
    save_category
    update_translations
    category
  end
  
  private
    def save_category
      category.attributes = category_params.merge(name: lodging_category_name(params[:lodging_category][:name]))
      category.save
    end
  
    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = category.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation).merge(name: lodging_category_name(translation[:name]))
        _translation.save
      end
    end
  
    def category_params
      params.require(:lodging_category).permit(:crm_id, :name)
    end
  
    def translation_params(translation)
      translation.permit(:name, :locale)
    end

    def lodging_category_name(name)
      return 'villa' if ['villa', 'villas', 'vakantiehuizen'].include?(name)
      return 'apartment' if ['apartment', 'apartments', 'appartementen'].include?(name)
      return 'bnb' if ['b&b'].include?(name)
      name
    end
end
