class Crm::V1::AdminUserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :full_name, :first_name, :last_name, :email,
             :token_expires_at

  attribute :auth_token, if: Proc.new { |user, params|
    params && params[:auth_token] == true
  }
end
