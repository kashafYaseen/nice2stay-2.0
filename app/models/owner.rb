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

  def full_name
    "#{first_name} #{last_name}".titleize
  end
end
