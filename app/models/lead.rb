class Lead < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin_user, optional: true
  has_many :offers
  has_many :lodgings, through: :offers

  has_and_belongs_to_many :countries
  has_and_belongs_to_many :regions

  validates :admin_user, :email_intro_en, :email_intro_nl, presence: true, on: :update

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :offers, allow_destroy: true, reject_if: :all_blank

  translates :notes, :email_intro
  globalize_accessors locales: [:en, :nl], attributes: [:email_intro]

  enum generated: {
    site_user: 0,
    site: 1,
    email: 2,
    phone: 3,
  }

  enum lead_type: {
    advice: 0,
    favorite: 1,
  }

  enum stay: {
    "1 day": 0,
    "2 - 3 days": 1,
    "1 week": 2,
    "2 weeks": 3,
    "3 weeks": 4,
    "more then 3 weeks": 5,
  }

  enum budget: {
    "0 - 200": 0,
    "200 - 300": 1,
    "300 - 400": 2,
    "400 - 500": 3,
    "500 or more": 4,
  }

  enum experience: {
    sport_and_recreation: 0,
    culture_and_history: 1,
    nature_and_wildlive: 2,
    other: 3,
  }

  enum default_status: {
    open: 0,
    offered: 1,
    first_reaction: 2,
    reminded: 3,
    closed: 4,
    booked: 5,
    option: 6,
    asked_for_more_info: 7,
    informed_availability: 8,
    customer_consulting: 9,
  }, _suffix: true
end
