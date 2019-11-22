class Api::V2::LodgingPricesSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :flexible_search

  attributes :price_details, if: Proc.new { |lodging, params| params.present? && params[:price_params].present? } do |lodging, params|
    Prices::GetInvoiceDetails.call(lodging, params[:price_params])
  end
end
