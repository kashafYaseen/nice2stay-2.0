class Api::V2::UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :full_name, :first_name, :last_name,
             :created_at, :updated_at

  attribute :auth_token, if: Proc.new { |user, params|
    params && params[:auth_token] == true
  }
end
