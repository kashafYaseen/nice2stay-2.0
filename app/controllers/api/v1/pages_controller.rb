class Api::V1::PagesController < Api::V1::ApiController
  def create
    @page = SavePageDetails.call(params)

    if @page.valid?
      render json: @page, status: :created
    else
      render json: @page.errors, status: :unprocessable_entity
    end
  end
end
