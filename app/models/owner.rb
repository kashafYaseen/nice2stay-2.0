class Owner < ApplicationRecord
  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :lodgings
  belongs_to :admin_user

  validates :email, uniqueness: true

  def full_name
    "#{first_name} #{last_name}".titleize
  end

  def invitation_status
    return "Accepted" if invitation_accepted_at? && invitation_sent_at?
    return "Pending" if invitation_accepted_at.blank? && invitation_sent_at?
    return "Not Registered"
  end

  def auth_token
    JsonWebToken.encode({ owner_id: self.id, exp: auth_expires_at.to_i })
  end

  def regenerate_auth_token
    JsonWebToken.encode({ owner_id: self.id, exp: update_token_expire_time.to_i })
  end

  def self.authenticate(email:, password:)
    owner = Owner.find_for_authentication(email: email)
    owner&.valid_password?(password) ? owner : nil
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
