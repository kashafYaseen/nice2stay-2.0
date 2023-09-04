class Crm::V1::Owner::SessionsController < Crm::V1::Owner::ApiController
  before_action :set_owner

  def create
    if (@owner&.invitation_status === 'Accepted')
      owner = Owner.authenticate(email: params[:email], password: params[:password])
      return invalid_credentials unless owner.present?

      owner.regenerate_auth_token
      render json: Crm::V1::OwnerSerializer.new(owner, { params: { auth_token: true } }).serialized_json, status: :created

    elsif (@owner&.invitation_status === 'Pending')

      render json: { errors: 'Please Accept the Invitation first' }, status: :unprocessable_entity
    else
      render json: { errors: 'You are not registered with Nice2Stay' }, status: :unprocessable_entity
    end

  end

  private
  def set_owner
    @owner = Owner.find_by(email: params[:email])
  end
end
