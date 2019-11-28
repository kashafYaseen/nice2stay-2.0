class Api::V2::AutocompletesController < Api::V2::ApiController
  def index
    render json: [
      {
        title: 'Countries',
        data: GetAutocompleteData.call({ query: params[:query], type: 'countries' }, locale)
      },
      {
        title: 'Regions',
        data: GetAutocompleteData.call({ query: params[:query], type: 'regions' }, locale),
      },
      {
        title: 'Popular Collection',
        data: GetAutocompleteData.call({ query: params[:query], type: 'campaigns' }, locale)
      },
      {
        title: 'Accommodations',
        data: GetAutocompleteData.call({ query: params[:query], type: 'lodgings' }, locale),
      },
    ]
  end
end
