class GuestDetail < ApplicationRecord
  belongs_to :reservation

  # Values based on CRM class and table names
  enum guest_type: {
    child: 'ChildDetail',
    person: 'PersonDetail',
  }
end
