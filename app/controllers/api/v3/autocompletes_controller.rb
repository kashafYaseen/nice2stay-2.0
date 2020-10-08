class Api::V3::AutocompletesController < Api::V2::ApiController
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
        title: 'Theme',
        data: GetAutocompleteData.call({ query: params[:query], type: 'themes' }, locale)
      },
      {
        title: 'Hotel',
        data: GetAutocompleteData.call({ query: params[:query], type: 'hotels' }, locale),
      },
    ]
  end
end
