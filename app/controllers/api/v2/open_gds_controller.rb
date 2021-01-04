class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    response = OpenGds::CreateRates.call(params[:_json])
    render json: { response: response.to_s }, status: response ? :ok : :unprocessable_entity
  end
end
