class Api::V2::CustomTextsController < Api::V2::ApiController
  before_action :set_custom_text, only: [:show]

  def index
    render json: {
      custom_texts: GetCustomTextData.call(locale),
    }, status: :ok
  end

  def show
    render json: Api::V2::CustomTextSerializer.new(@custom_text.first, params: { locale: params[:locale] }).serializable_hash, status: :ok
  end

  private
    def set_custom_text
      @custom_text = CustomText.search(where: { "seo_path_#{params[:locale]}": params[:seo_path] }, load: false)
    end
end
