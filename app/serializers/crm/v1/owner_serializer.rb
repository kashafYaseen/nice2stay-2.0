class Crm::V1::OwnerSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :full_name, :first_name, :last_name, :email,
             :invitation_accepted_at, :admin_user_id, :business_name, :account_id,
             :email_boolean, :not_interested, :language, :updating_availability,
             :automated_availability, :country_id, :region_id

  attribute :auth_token, if: Proc.new { |user, params|
    params && params[:auth_token] == true
  }

  attributes :admin_user_name do |owner|
    owner.admin_user.try(:full_name)
  end

  attributes :country_name do |owner|
    owner.country.try(:name)
  end

  attributes :region_name do |owner|
    owner.region.try(:name)
  end
end
