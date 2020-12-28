class Api::V2::OpenGdsController < Api::V2::ApiController
  def create
    # data = params[:_json]
    OpenGds::CreateRates.call(params[:_json])
  end
end
