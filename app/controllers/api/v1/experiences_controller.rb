class Api::V1::ExperiencesController < Api::V1::ApiController
  before_action :set_locale, only: [:index]

  def index
    render json: Api::V2::ExperienceSerializer.new(Experience.includes(:translations)).serialized_json, status: :ok
  end

  def create
    @experience = SaveExperienceDetails.call(params)

    if @experience.valid?
      render json: @experience, status: :created
    else
      unprocessable_entity(@experience.errors)
    end
  end

  private
    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end
end
