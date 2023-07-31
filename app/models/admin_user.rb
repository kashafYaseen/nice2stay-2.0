class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  def full_name
    "#{first_name} #{last_name}"
  end

  def auth_token
    JsonWebToken.encode({ admin_user_id: self.id, exp: auth_expires_at.to_i })
  end

  def regenerate_auth_token
    JsonWebToken.encode({ admin_user_id: self.id, exp: update_token_expire_time.to_i })
  end

  def self.authenticate(email:, password:)
    user = AdminUser.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end

  def auth_expires_at
    self.token_expires_at || update_token_expire_time
  end

  def update_token_expire_time
    expire_time = Time.now.to_i + 86400
    self.update_columns token_expires_at: expire_time
    expire_time
  end

end
