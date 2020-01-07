class Api::V1::PagesController < Api::V1::ApiController
  def create
    @page = SavePageDetails.call(params)

    if @page.valid?
      render json: @page, status: :created
    else
      unprocessable_entity(@page.errors)
    end
  end
end
