class Synchronization::SaveGcOfferDetails
  attr_reader :params
  attr_reader :gc_offer
  attr_reader :lodging

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @lodging = Lodging.friendly.find(params[:lodging])
    @gc_offer = @lodging.gc_offers.find_or_initialize_by(offer_id: gc_offer_params[:offer_id])
  end

  def call
    save_gc_offer
    update_translations_for gc_offer, params
    gc_offer
  end

  private
    def save_gc_offer
      gc_offer.attributes = gc_offer_params
      gc_offer.save(validate: false)
    end

    def update_translations_for object, params
      if params[:translations].present?
        params[:translations].each do |translation|
          _translation = object.translations.find_or_initialize_by(locale: translation[:locale])
          _translation.attributes = translation_params(translation)
          _translation.save
        end
      end
    end

    def gc_offer_params
      params.require(:gc_offer).permit(
        :name,
        :offer_id,
        :short_description,
        :description,
      )
    end

    def translation_params(translation)
      translation.permit(
        :name,
        :short_description,
        :description,
        :locale,
      )
    end
end
