class UpdateLodgingPriceText
  attr_reader :lodging
  attr_reader :params
  attr_reader :price_text

  def self.call(lodging, params)
    self.new(lodging, params).call
  end

  def initialize(lodging, params)
    @lodging = lodging
    @params = params
    @price_text = lodging.price_text || lodging.build_price_text
  end

  def call
    return unless params.present?
    update_translations if update_price_text
  end

  private
    def update_price_text
      price_text.attributes = price_text_params
      price_text.save
    end

    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = price_text.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def price_text_params
      params.permit(
        :season_text,
        :including_text,
        :pay_text,
        :deposit_text,
        :options_text,
        :particularities_text,
        :payment_terms_text,
      )
    end

    def translation_params(translation)
      translation.permit(
        :season_text,
        :including_text,
        :pay_text,
        :deposit_text,
        :options_text,
        :particularities_text,
        :payment_terms_text,
        :locale,
      )
    end
end
