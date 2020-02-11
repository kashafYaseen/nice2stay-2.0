class Api::V2::GcRoomsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_lodging

  def show
    render json: Api::V2::LodgingSerializer.new(@lodging.find_gc_room(params[:id])).serialized_json, status: :ok
  end

  private
    def set_lodging
      @lodging = Lodging.published.friendly.find(params[:lodging_id])
    end
end
