class SaveAmenityDetails
  attr_reader :params
  attr_reader :amenity

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @amenity = Amenity.find_or_initialize_by(slug: amenity_params[:slug])
  end

  def call
    save_amenity
    save_lodgings
    update_translations
    amenity
  end

  private
    def save_amenity
      amenity.attributes = amenity_params
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

    def amenity_params
      params.require(:amenity).permit(
        :slug,
        :name,
        :filter_enabled,
        :hot,
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

