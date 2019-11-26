class Api::V2::AutocompletesController < Api::V2::ApiController
  def index
    render json: {
      lodgings: GetAutocompleteData.call({ query: params[:query], type: 'lodgings' }, locale),
      campaigns: GetAutocompleteData.call({ query: params[:query], type: 'campaigns' }, locale),
      countries: GetAutocompleteData.call({ query: params[:query], type: 'countries' }, locale),
      regions: GetAutocompleteData.call({ query: params[:query], type: 'regions' }, locale),
    }
  end
end
