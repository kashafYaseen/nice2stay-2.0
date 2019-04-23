class SavePlaceDetails
  attr_reader :params
  attr_reader :place

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @place = Place.find_or_initialize_by(slug: place_params[:slug])
  end

  def call
    save_place
    update_translations_for place, params
    update_translations_for place.place_category, params[:place_category]
    place
  end

  private
    def place_category
      category = PlaceCategory.find_or_initialize_by(slug: place_category_params[:slug])
      category.attributes = place_category_params
      category.save
      category
    end

    def save_place
      place.attributes = place_params
      place.country = Country.friendly.find(params[:country]) rescue nil
      place.region = Region.friendly.find(params[:region]) rescue nil
      place.place_category = place_category
      place.save(validate: false)
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

    def place_params
      params.require(:place).permit(
        :name,
        :address,
        :details,
        :description,
        :publish,
        :slug,
        :spotlight,
        :header_dropdown,
        :short_desc,
        :short_desc_nav,
        :latitude,
        :longitude,
        { images: [] },
      )
    end

    def translation_params(translation)
      translation.permit(
        :details,
        :description,
        :name,
        :slug,
        :locale,
      )
    end

    def place_category_params
      params.require(:place_category).permit(
        :name,
        :slug,
        :color_code,
      )
    end

    def category_translation_params(translation)
      translation.permit(
        :name,
        :slug,
        :locale,
      )
    end
end
