class Crm::V1::AdminUser::CustomTextsController < Crm::V1::ApiController
  before_action :authenticate
  before_action :set_custom_text, only:%i[update destroy]

  def index
    render json: Crm::V1::CustomTextSerializer.new(CustomText.all).serialized_json, status: :ok

  end

  def new
  end

  def create
    @custom_text = CustomText.new(custom_text_params)
    if @custom_text.save
      render json: Crm::V1::CustomTextSerializer.new(@custom_text).serialized_json, status: :ok
    else
      unprocessable_entity(@custom_text.errors)
    end
  end

  def edit
  end

  def update
    if @custom_text.update(custom_text_params)
      render json: Crm::V1::CustomTextSerializer.new(@custom_text).serialized_json, status: :ok
    else
      unprocessable_entity(@custom_text.errors)
    end
  end

  def destroy
    @custom_text.destroy
    render json: { removed: @custom_text.destroyed? }, status: :ok
  end

  private
    def set_custom_text
      @custom_text = CustomText.find(params[:id])
    end

    def custom_text_params
      params.require(:custom_text).permit(
        :h1_text_en,
        :h1_text_nl,
        :menu_title_en,
        :menu_title_nl,
        :meta_title_en,
        :meta_title_nl,
        :p_text_en,
        :p_text_nl,
        :meta_description_en,
        :meta_description_nl,
        # :tag_id,
        # :category_id,
        :region_id,
        :country_id,
        :homepage,
        :country_page,
        :region_page,
        :navigation_popular,
        :navigation_country,
        :inspiration,
        :popular,
        :show_page,
        :special_offer,
        # image_attributes: [:id, :image],
        # :collections_attributes => [:id, :relative_id, :_destroy])
        :collections_attributes => [:id, :relative_id]
      )
    end
end
