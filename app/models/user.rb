class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  belongs_to :country, optional: true
  has_many :reviews
  has_many :wishlists
  has_many :favourite_lodgings, through: :wishlists, source: :lodging
  has_many :leads
  has_many :bookings
  has_many :reservations, through: :bookings
  has_many :notifications
  has_many :visits, class_name: "Ahoy::Visit"
  has_many :events, class_name: "Ahoy::Event"

  mount_uploader :image, ImageUploader

  delegate :in_cart, :non_confirmed, :confirmed_options, :requests, to: :reservations, allow_nil: true, prefix: true
  delegate :active, to: :wishlists, allow_nil: true, prefix: true
  delegate :in_cart, :confirmed, to: :bookings, allow_nil: true, prefix: true
  delegate :recent, to: :notifications, allow_nil: true, prefix: true
  delegate :name, :slug, to: :country, allow_nil: true, prefix: true

  validates :email, uniqueness: { message: "has an account. Click here to <input type='button' name='login-form' value='Login' class='btn btn-link btn-danger btn-sm' data-toggle='modal' data-target='#login-form-modal'>or here to <input type='button' name='reset-password-form' value='Reset password' class='btn btn-link btn-danger btn-sm' data-toggle='modal' data-target='#reset-pass-form-modal'>" }, allow_blank: true
  validates :first_name, :last_name, :phone, presence: true, unless: :encrypted_password_changed?
  validates :city, :address, :country, presence: true, unless: :skip_validations?
  before_validation :set_password

  attr_accessor :skip_validations

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
    bookings.build.save(validate: false) unless bookings_in_cart.present?
    bookings_in_cart.take
  end

  def skip_validations?
    encrypted_password_changed? || skip_validations
  end

  def front_chat_hash
    hash = Digest::SHA2.new(256)
    hash << ENV['FRONT_CHAT_SECRET']
    hash << email
    hash.hexdigest
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    User.find_by(email: data['email']) || User.create(first_name: data['first_name'], last_name: data['last_name'], email: data['email'], password: Devise.friendly_token[0,20], image: data['image'])
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

    def set_password
      return if with_login? || password.present? || password_confirmation.present?
      self.password = self.password_confirmation = Devise.friendly_token[0, 20]
    end
end
