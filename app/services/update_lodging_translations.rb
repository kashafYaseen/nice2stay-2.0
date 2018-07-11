class UpdateLodgingTranslations
  attr_reader :lodging
  attr_reader :translations

  def self.call(lodging, translations)
    self.new(lodging, translations).call
  end

  def initialize(lodging, translations)
    @lodging = lodging
    @translations = translations
  end

  def call
    return unless translations.present?
    update_translations
  end

  private
    def update_translations
      translations.each do |translation|
        _translation = lodging.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def translation_params(translation)
      translation.permit(
        :h1,
        :h2,
        :h3,
        :highlight_1,
        :highlight_2,
        :highlight_3,
        :summary,
        :short_desc,
        :location_description,
        :locale,
        :title,
        :description,
        :meta_desc,
      )
    end
end
