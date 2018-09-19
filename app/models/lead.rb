class Lead < ApplicationRecord
  belongs_to :user, optional: true
  has_and_belongs_to_many :countries

  accepts_nested_attributes_for :user

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
  }
end
