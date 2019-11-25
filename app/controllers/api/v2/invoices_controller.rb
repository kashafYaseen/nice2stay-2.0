class Api::V2::InvoicesController < Api::V2::ApiController
  before_action :set_lodging

  def show
    render json: Api::V2::LodgingPricesSerializer.new(@lodging, price_options).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end

    def price_options
      { params: { price_params: params } }
    end
end
