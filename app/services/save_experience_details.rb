class SaveExperienceDetails
  attr_reader :params
  attr_reader :experience

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @experience = Experience.find_or_initialize_by(slug: experience_params[:slug])
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
      return unless params[:lodgings].present?
      params[:lodgings].each do |lodging_params|
        lodging = Lodging.find_by(slug: lodging_params[:slug])
        next unless lodging.present?
        experience.lodgings << lodging unless experience.lodgings.find_by(id: lodging.id).present?
      end
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
        :tag,
        :short_desc,
        :publish,
      )
    end

    def translation_params(translation)
      translation.permit(
        :slug,
        :name,
      )
    end

end

