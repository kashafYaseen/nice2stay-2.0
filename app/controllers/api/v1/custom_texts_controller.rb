class Api::V1::CustomTextsController < Api::V1::ApiController
  def create
    @custom_text = CustomText.find_or_initialize_by(crm_id: custom_text_params[:crm_id])
    @custom_text.attributes = custom_text_params
    @custom_text.country = Country.find_by(slug: params[:custom_text][:country_slug])
    @custom_text.region = Region.find_by(slug: params[:custom_text][:region_slug])
    @custom_text.experience = Experience.find_by(slug: params[:custom_text][:experience_slug])

    if @custom_text.save(validate: false)
      update_translations(params, @custom_text)
      render json: @custom_text, status: :created
    else
      render json: @custom_text.errors, status: :unprocessable_entity
    end
  end

  def update_translations(params, custom_text)
    return unless params[:translations].present?
    params[:translations].each do |translation|
      _translation = custom_text.translations.find_or_initialize_by(locale: translation[:locale])
      _translation.attributes = translation_params(translation)
      _translation.save
    end
  end

  private
    def custom_text_params
      params.require(:custom_text).permit(
        :crm_id,
        :h1_text,
        :p_text,
        :meta_title,
        :meta_description,
        :category,
        :homepage,
        :country_page,
        :region_page,
        :navigation_popular,
        :navigation_country,
        :image,
        :seo_path,
        :menu_title,
      )
    end

    def translation_params(translation)
      translation.permit(
        :h1_text,
        :p_text,
        :meta_title,
        :meta_description,
        :locale,
        :category,
        :experience,
        :seo_path,
        :menu_title,
      )
    end
end
