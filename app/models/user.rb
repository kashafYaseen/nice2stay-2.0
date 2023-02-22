require './lib/recommendation.rb'

class User < ApplicationRecord
  include Reccommendation
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: SocialLogin::SOCIAL_SITES

  belongs_to :country, optional: true
  has_many :reviews
  has_many :wishlists
  has_many :favourite_lodgings, through: :wishlists, source: :lodging
  has_many :leads
  has_many :bookings
  has_many :reservations, through: :bookings
  has_many :reserved_lodgings, through: :reservations, source: :lodging
  has_many :notifications
  has_many :social_logins
  has_many :visits, class_name: "Ahoy::Visit"
  has_many :events, class_name: "Ahoy::Event"
  has_many :vouchers, foreign_key: :receiver_id
  has_many :trip_members
  has_many :trips, through: :trip_members
  has_many :recent_searches
  has_and_belongs_to_many :visited_lodgings, class_name: 'Lodging', join_table: 'visited_lodgings'

  has_one :first_visit, -> (user) { order(:started_at).where("started_at < ?", user.created_at) }, class_name: 'Ahoy::Visit'

  mount_uploader :image, ImageUploader

  delegate :in_cart, :non_confirmed, :confirmed_options, :requests, to: :reservations, allow_nil: true, prefix: true
  delegate :active, to: :wishlists, allow_nil: true, prefix: true
  delegate :in_cart, :confirmed, to: :bookings, allow_nil: true, prefix: true
  delegate :recent, to: :notifications, allow_nil: true, prefix: true
  delegate :name, :code, :slug, to: :country, allow_nil: true, prefix: true
  delegate :with_lodgings, to: :history_lodgings, allow_nil: true, prefix: :history
  delegate :unsed, :old, to: :vouchers, allow_nil: true, prefix: true

  validates :email, uniqueness: { message: "has an account. Click here to <input type='button' name='login-form' value='Login' class='btn btn-link btn-danger btn-sm' data-toggle='modal' data-target='#login-form-modal'>or here to <input type='button' name='reset-password-form' value='Reset password' class='btn btn-link btn-danger btn-sm' data-toggle='modal' data-target='#reset-pass-form-modal'>" }, allow_blank: true
  validates :first_name, :last_name, :phone, presence: true, unless: :skip_validations?
  validates :city, :address, :country, presence: true, unless: :skip_validations?
  before_validation :set_password

  accepts_nested_attributes_for :social_logins

  attr_accessor :skip_validations

  enum creation_status: {
    with_login: 0,
    without_login: 1,
    with_social_site: 2,
  }

  def full_name
    "#{first_name} #{last_name}".titleize
  end

  def auth_token
    JsonWebToken.encode({ user_id: self.id, exp: auth_expires_at.to_i })
  end

  def regenerate_auth_token
    JsonWebToken.encode({ user_id: self.id, exp: update_token_expire_time.to_i })
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

  def self.configure_social_login_user(uid:, provider:, email:, first_name:, last_name:)
    user = User.find_by(email: email)
    return user if user

    user = User.create(email: email, password: Devise.friendly_token[0,20], first_name: first_name, last_name: last_name)
    user.social_logins.find_or_create_by(uid: uid, provider: provider) do |social_login|
      social_login.email = email
      social_login.confirmed_at = DateTime.current
    end
    user
  end

  def self.from_omniauth(access_token)
    find_by_provider_and_uid(access_token['provider'], access_token['uid']) || create_by_user(access_token)
  end

  def invitation_status
    return "Pending"  if invitation_accepted_at.blank? && !invitation_sent_at.blank?
    return "Accepted"
  end

  def reserved_lodging_slugs
    reserved_lodgings.map(&:slug).uniq
  end

  def generate_reset_token
    token, enc_token = Devise.token_generator.generate(User, :reset_password_token)
    self.update_columns(reset_password_token: enc_token, reset_password_sent_at: Time.now)
    UserMailer.forgot_password_email(self, token).deliver_now
  end

  private
    def self.find_by_provider_and_uid provider, uid
      joins(:social_logins).where("social_logins.provider = ? and social_logins.uid = ? and social_logins.confirmed_at is not ?", provider, uid, nil).take
    end

    def self.create_by_user access_token
      data = access_token['info']
      user = find_by(email: data['email'])

      user.social_logins.find_or_create_by(uid: access_token['uid'], provider: access_token['provider']) do |social_login|
        social_login.email = data['email']
        social_login.confirmed_at = DateTime.current
      end if user.present?
      user
    end

    def self.build_by_provider access_token
      data = access_token['info']

      new(
        first_name: auth_first_name(data),
        last_name: auth_last_name(data),
        email: data['email'],
        password: Devise.friendly_token[0,20],
        social_logins_attributes: [{ provider: access_token['provider'], uid: access_token['uid'], email: data['email'] }]
      )
    end

    def self.auth_first_name data
      return data['first_name'] if data['first_name'].present?
      return data['full_name'].split(' ').first if data['full_name'].present?
      return data['name'].split(' ').first if data['name'].present?
    end

    def self.auth_last_name data
      return data['last_name'] if data['last_name'].present?
      return data['full_name'].split(' ').last if data['full_name'].present?
      return data['name'].split(' ').last if data['name'].present?
    end

    def auth_expires_at
      self.token_expires_at || update_token_expire_time
    end

    def update_token_expire_time
      expire_time = Time.now.to_i + 86400
      self.update_columns token_expires_at: expire_time
      expire_time
    end

    def set_password
      return if with_login? || persisted? || password.present? || password_confirmation.present?
      self.password = self.password_confirmation = Devise.friendly_token[0, 20]
    end
end
