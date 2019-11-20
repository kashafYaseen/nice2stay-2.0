class Api::V2::InvoicesController < Api::V2::ApiController
  before_action :set_lodging

  def show
    render json: Prices::GetInvoiceDetails.call(@lodging, params), status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end
end
