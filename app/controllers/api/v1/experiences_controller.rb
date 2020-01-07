class Api::V1::ExperiencesController < Api::V1::ApiController
  def create
    @experience = SaveExperienceDetails.call(params)

    if @experience.valid?
      render json: @experience, status: :created
    else
      unprocessable_entity(@experience.errors)
    end
  end
end
