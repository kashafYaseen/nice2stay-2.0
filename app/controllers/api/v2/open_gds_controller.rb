class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    response = OpenGds::CreateRates.call(params[:_json])
    render status: response ? :ok : :unprocessable_entity
  end
end
