class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :reservations
  has_many :reviews

  delegate :in_cart, to: :reservations, allow_nil: true, prefix: true

  def full_name
    "#{first_name} #{last_name}".titleize
  end

  def auth_token
    JsonWebToken.encode({ user_id: self.id, exp: auth_expires_at })
  end

  def regenerate_auth_token
    JsonWebToken.encode({ user_id: self.id, exp: update_token_expire_time })
  end

  def self.authenticate(email:, password:)
    user = User.find_for_authentication(email: email)
    user&.valid_password?(password) ? user : nil
  end

  private
    def auth_expires_at
      self.token_expires_at || update_token_expire_time
    end

    def update_token_expire_time
      expire_time = Time.now.to_i + 86400
      self.update_columns token_expires_at: expire_time
      expire_time
    end
end
