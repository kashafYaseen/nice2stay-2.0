class Crm::V1::UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :full_name, :first_name, :last_name, :email,
             :image_url, :address, :language,
             :mollie_id, :city, :zipcode, :country_id, :creation_status,
             :unconfirmed_email, :phone, :token_expires_at

  attribute :auth_token, if: Proc.new { |user, params|
    params && params[:auth_token] == true
  }
end
