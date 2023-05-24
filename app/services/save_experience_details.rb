class SaveExperienceDetails
  attr_reader :params
  attr_reader :experience

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @experience = Experience.find_or_initialize_by(crm_id: experience_params[:crm_id])
  end

  def call
    save_experience
    save_lodgings
    update_translations
    experience
  end

  private
    def save_experience
      experience.attributes = experience_params
      experience.save
    end

    def save_lodgings
      lodgings = Lodging.where(slug: params[:lodgings])
      experience.lodgings = lodgings
    end

    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = experience.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def experience_params
      params.require(:experience).permit(
        :slug,
        :name,
        :crm_id,
        :tag,
        :short_desc,
        :publish,
        :priority,
        :guests,
        :crm_id,
        :created_at,
        :updated_at,
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
end
