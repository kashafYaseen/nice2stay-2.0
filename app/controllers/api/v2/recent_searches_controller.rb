class Api::V2::RecentSearchesController < Api::V2::ApiController
  before_action :authenticate

  def index
    render json: Api::V2::RecentSearchSerializer.new(current_user.recent_searches.upcoming_searches.includes(:searchable)).serialized_json, status: :ok
  end

  def create
    recent_search = current_user.recent_searches.new(recent_search_params)
    if recent_search.save
      render json: Api::V2::RecentSearchSerializer.new(recent_search).serialized_json, status: :created
    else
      unprocessable_entity(recent_search.errors)
    end
  end

  def destroy
    current_user.recent_searches.destroy_all
    head :no_content
  end

  private
    def recent_search_params
      params.require(:recent_search).permit(
        :searchable_id,
        :searchable_type,
        :check_in,
        :check_out,
        :adults,
        :children,
        :infants
      )
    end
end
