class Crm::V1::AdminUser::ExperiencesController < Crm::V1::ApiController

  before_action :get_experience, only: [:edit, :update, :destroy]

  def index
    render json: Crm::V1::ExperienceSerializer.new(Experience.all).serialized_json, status: :ok
  end

  def new
  end

  def create
    @experience = Experience.new(experience_params)
    if @experience.save
      @success = true
      render json: Crm::V1::ExperienceSerializer.new(@experience).serialized_json, status: :ok
    else
      @success = false
      unprocessable_entity(@experience.errors)
    end
  end

  def edit
  end

  def update
    if @experience.update(experience_params)
      @success = true
      render json: Crm::V1::ExperienceSerializer.new(@experience).serialized_json, status: :ok
    else
      @success = false
      unprocessable_entity(@experience.errors)
    end
  end

  def destroy
    if @experience.destroy
      @success = true
      render json: { removed: @experience.destroyed? }, status: :ok
    else
      @success = false
      unprocessable_entity(@experience.errors)
    end
  end

  private

    def get_experience
      @experience = Experience.friendly.find(params[:id])
    end

    def experience_params
      params.require(:experience).permit(
        :name_en,
        :name_nl,
        :slug_en,
        :slug_nl,
        :short_desc,
        :publish,
        :priority,
        :guests,
        :image_attributes => [:id, :image]
      )
    end
end
