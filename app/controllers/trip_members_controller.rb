class TripMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip

  def new
    @user = User.new
  end

  def create
    flash.now[:notice] = Invites::InviteUser.call(@trip, current_user, member_params)
  end

  def destroy
    trip_member = @trip.trip_members.find(params[:id])
    if trip_member.destroy
      redirect_to new_trip_trip_member_path(@trip), notice: "Member was removed successfully"
    else
      redirect_to new_trip_trip_member_path(@trip), alert: "Unable to remove member, please try again."
    end
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
