class Owner < ApplicationRecord
  devise :database_authenticatable, :registerable, :invitable,
         :recoverable, :rememberable, :trackable

  has_many :lodgings
  belongs_to :admin_user
  belongs_to :country
  belongs_to :region, optional: true

  validates :email, uniqueness: true

  scope :active_partners, -> {where(email_boolean: true)}
  scope :inactive_partners, -> {where(email_boolean: false)}

  scope :commission_by_years, -> do
    joins("LEFT OUTER JOIN lodgings ON lodgings.owner_id = owners.id LEFT OUTER JOIN reservations ON reservations.lodging_id = lodgings.id")
    .select("owners.*,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '7 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_7_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '6 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_6_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '5 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_5_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '4 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_4_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '3 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_3_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '2 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_2_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() - interval '1 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_previous_1_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now() + interval '1 year') AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_next_1_year,
      COALESCE(SUM(CASE WHEN (extract(year from reservations.check_in) = date_part('year', now()) AND reservations.booking_status >= '0' AND reservations.booking_status <= '7' AND reservations.request_status IN ('0', '1')) THEN reservations.commission END), 0) as commission_current_year"
    )
    .group("owners.id")
  end

  validates :email, uniqueness: true

  def full_name
    "#{first_name} #{last_name}".titleize
  end

  def invitation_status
    return 'Accepted' if invitation_accepted_at? && invitation_sent_at?
    return 'Pending' if invitation_accepted_at.blank? && invitation_sent_at?
    return 'Not Registered'
  end

  def auth_token
    JsonWebToken.encode({ owner_id: id, exp: auth_expires_at.to_i })
  end

  def regenerate_auth_token
    JsonWebToken.encode({ owner_id: id, exp: update_token_expire_time.to_i })
  end

  def self.authenticate(email:, password:)
    owner = Owner.find_for_authentication(email: email)
    owner&.valid_password?(password) ? owner : nil
  end

  def auth_expires_at
    token_expires_at || update_token_expire_time
  end

  def update_token_expire_time
    expire_time = Time.now.to_i + 86400
    update_columns token_expires_at: expire_time
    expire_time
  end
end
