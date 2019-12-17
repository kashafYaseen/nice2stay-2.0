class Api::V2::UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :full_name, :first_name, :last_name, :email,
             :created_at, :updated_at, :image_url, :address, :language

  attribute :auth_token, if: Proc.new { |user, params|
    params && params[:auth_token] == true
  }
end
