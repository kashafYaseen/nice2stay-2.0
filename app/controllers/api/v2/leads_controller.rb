class Api::V2::LeadsController < Api::V2::ApiController
  before_action :set_user_if_present

  def create
    lead = current_user.present? ? current_user.leads.build(lead_params) : Lead.new(lead_and_user_params)
    current_user.skip_validations = true if current_user.present?

    if lead.save
      render json: Api::V2::LeadSerializer.new(lead, { params: { auth: true } }).serialized_json, status: :ok
    else
      unprocessable_entity(lead.errors)
    end
  end

  private
    def lead_and_user_params
      params.require(:lead).permit(
        :from,
        :to,
        :adults,
        :childrens,
        :extra_information,
        { country_ids: [] },
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
        { country_ids: [] },
      )
    end
end
