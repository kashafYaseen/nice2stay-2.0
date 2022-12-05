class Api::V3::AutocompletesController < Api::V2::ApiController
  before_action :set_user_if_present

  def index
    render json: [
      {
        title: 'Visited Accommodations',
        type: 'visited_lodgings',
        data: GetAutocompleteData.call(query_params.merge(type: 'visited_lodgings'), locale)
      },{
        title: 'Recent Searches',
        type: 'recent_searches',
        data: GetAutocompleteData.call(query_params.merge(type: 'recent_searches'), locale)
      },{
        title: 'Countries',
        type: 'countries',
        data: GetAutocompleteData.call(query_params.merge(type: 'countries'), locale)
      },{
        title: 'Regions',
        type: 'regions',
        data: GetAutocompleteData.call(query_params.merge(type: 'regions'), locale),
      },{
        title: 'Theme',
        type: 'themes',
        data: GetAutocompleteData.call(query_params.merge(type: 'themes'), locale)
      },{
        title: 'Hotel',
        type: 'hotels',
        data: GetAutocompleteData.call(query_params.merge(type: 'hotels'), locale),
      },
      {
        title: 'Campaign',
        type: 'campaigns',
        data: GetAutocompleteData.call(query_params.merge(type: 'campaigns'), locale),
      }
    ]
  end

  private
    def query_params
      { query: params[:query], user_id: current_user.try(:id) }
    end
end
