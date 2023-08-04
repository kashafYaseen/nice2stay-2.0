class Crm::V1::Owner::InvitationsController < Crm::V1::Owner::ApiController
  before_action :set_owner, only: [:update]

  def edit
    redirect_to 'http://127.0.0.1:5173/business-owner/invitation-form'
  end

  def update
    if (@owner.invitation_accepted_at.nil?)
      @owner.invitation_accepted_at = Time.now
      if @owner.update(owner_params)
        authToken = auth_token
        exp_time = update_token_expire_time
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

    def auth_token
      JsonWebToken.encode({ owner_id: @owner.id, exp: update_token_expire_time })
    end

    def update_token_expire_time
      expire_time = Time.now.to_i + 86400
      @owner.update_columns token_expires_at: expire_time
      expire_time
    end
end
