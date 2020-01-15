class Invites::InviteUser
  attr_reader :params
  attr_reader :trip
  attr_reader :user
  attr_reader :current_user

  def self.call(trip, current_user, params)
    self.new(trip, current_user, params).call
  end

  def initialize(trip, current_user, params)
    @trip = trip
    @params = params
    @current_user = current_user
  end

  def call
    @user = User.find_by(email: params[:email])
    return add_trip_member if user.present?
    invite_member
  end

  private
    def add_trip_member
      trip.users << user unless trip.users.include? user
      "Member was added successfully."
    end

    def invite_member
      @user = User.invite!(params, current_user)
      @trip.users << @user
      "Member was invited successfully"
    end
end
