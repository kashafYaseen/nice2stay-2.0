class Api::V2::TripMembersController < Api::V2::ApiController
  before_action :authenticate
  before_action :set_trip

  def create
    render json: { message: Invites::InviteUser.call(@trip, current_user, member_params) }, status: :created
  end

  def destroy
    trip_member = @trip.trip_members.find(params[:id])
    trip_member.destroy
    render json: { removed: trip_member.destroyed? }, status: :ok
  end

  private
    def set_trip
      @trip = current_user.trips.find(params[:trip_id])
    end

    def member_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
      )
    end
end
