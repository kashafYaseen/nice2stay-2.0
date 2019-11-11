class Lead < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :admin_user, optional: true
  has_many :offers
  has_many :lodgings, through: :offers

  has_and_belongs_to_many :countries

  validates :admin_user, presence: true, on: :update

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :offers, allow_destroy: true, reject_if: :all_blank

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
