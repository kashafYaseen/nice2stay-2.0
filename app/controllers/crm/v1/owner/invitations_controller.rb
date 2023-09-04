class Crm::V1::Owner::InvitationsController < Crm::V1::Owner::ApiController
  before_action :set_owner, only: [:update]

  def edit
    redirect_to "#{ENV['OWNER_INVITE_FORM']}"
  end

  def update
    if (@owner.invitation_accepted_at.nil?)
      @owner.invitation_accepted_at = Time.now
      @owner.invitation_token = nil
      if @owner.update(owner_params)
        authToken = @owner.auth_token
        exp_time = @owner.update_token_expire_time
        render json: {auth_token: authToken, token_expires_at: exp_time }, status: :ok
      else
        render json: {error: 'Something went wrong' }, status: :unprocessable_entity
      end
    else
      render json: {error: 'You have already accepted the invitation' }, status: :unprocessable_entity
    end
  end

  protected

    def set_owner
      @owner = Owner.find_by(email: params[:owner][:email])
    end

    def owner_params
      params.require(:owner).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :invitation_accepted_at
      )
    end
end
