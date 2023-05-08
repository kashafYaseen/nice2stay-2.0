class Api::V2::LeadsController < Api::V2::ApiController
  before_action :set_user_if_present
  before_action :set_user, only: [:create]

  def create
    lead = @user.leads.build(lead_params)

    if lead.save
      render json: Api::V2::LeadSerializer.new(lead, { params: { auth: true } }).serialized_json, status: :ok
    else
      unprocessable_entity(lead.errors)
    end
  end

  private
    def set_user
      current_user.skip_validations = true if current_user.present?
      return @user = current_user if current_user.present?

      if params[:create_account].present?
        @user = User.with_login.new(lead_and_user_params)
      else
        @user = User.without_login.find_or_initialize_by(email: params[:lead][:user_attributes][:email])
        @user.attributes = user_params
        @user.password = @user.password_confirmation = Devise.friendly_token[0, 20]
        @user.save
      end
    end

    def user_params
      params.require(:lead).require(:user_attributes).permit(:first_name, :last_name, :phone, :email)
    end

    def lead_and_user_params
      params.require(:lead).permit(
        :from,
        :to,
        :adults,
        :childrens,
        :extra_information,
        :stay,
        :experience,
        :budget,
        { country_ids: [] },
        { region_ids: [] },
        user_attributes: [:first_name, :last_name, :email, :phone, :password, :password_confirmation, :skip_validations],
      )
    end

    def lead_params
      params.require(:lead).permit(
        :from,
        :to,
        :adults,
        :childrens,
        :extra_information,
        :stay,
        :experience,
        :budget,
        { country_ids: [] },
        { region_ids: [] },
      )
    end
end
