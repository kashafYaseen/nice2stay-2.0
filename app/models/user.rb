class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :reservations
  has_many :reviews
  has_many :wishlists
  has_many :favourite_lodgings, through: :wishlists, source: :lodging
  has_many :leads
  has_many :bookings

  mount_uploader :image, ImageUploader

  delegate :in_cart, :requests, to: :reservations, allow_nil: true, prefix: true
  delegate :active, to: :wishlists, allow_nil: true, prefix: true
  delegate :requests_pending_or_rejected, :requests_confirmed, to: :reservations, allow_nil: true
  delegate :in_cart, to: :bookings, allow_nil: true, prefix: true

  validates :first_name, :last_name, presence: true

  enum creation_status: {
    with_login: 0,
    without_login: 1,
  }

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

  def cart_items_count
    reservations_in_cart.count
  end

  def cart_subtotal
    reservations_in_cart.sum(:total_price)
  end

  def booking_in_cart
    bookings.create unless bookings_in_cart.present?
    bookings_in_cart.take
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
