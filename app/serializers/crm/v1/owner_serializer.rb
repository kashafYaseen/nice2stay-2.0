class Crm::V1::OwnerSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :full_name, :first_name, :last_name, :email,
              :pre_payment, :final_payment, :invitation_accepted_at, :admin_user_id, :token_expires_at

  attribute :auth_token, if: Proc.new { |user, params|
    params && params[:auth_token] == true
  }

  attributes :admin_user_name do |owner|
    owner.admin_user.try(:full_name)
  end
end
