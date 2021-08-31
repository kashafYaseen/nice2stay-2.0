class Api::V1::OwnersController < Api::V1::ApiController
  before_action :set_owner, only: [:create]

  def create
    if @owner.update(owner_params)
      head :ok
    else
      unprocessable_entity(@owner.errors)
    end
  end

  private
    def set_owner
      @owner = Owner.find_by(email: owner_params[:email])
    end

    def owner_params
      params.require(:owner).permit(:email, :first_name, :last_name, :pre_payment, :final_payment, :sign_in_count)
    end
end
