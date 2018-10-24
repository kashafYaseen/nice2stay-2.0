class Api::V1::CustomTextsController < Api::V1::ApiController
  def create
    @custom_text = CustomText.find_or_initialize_by(crm_id: custom_text_params[:crm_id])
    @custom_text.attributes = custom_text_params

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
        :redirect_url,
        :country,
        :region,
        :category,
        :experience,
      )
    end

    def translation_params(translation)
      translation.permit(
        :h1_text,
        :p_text,
        :meta_title,
        :meta_description,
        :redirect_url,
        :locale,
        :country,
        :region,
        :category,
        :experience,
      )
    end
end
