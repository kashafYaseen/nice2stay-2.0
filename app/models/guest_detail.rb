class GuestDetail < ApplicationRecord
  belongs_to :reservation

  # ENUM type is based on CRM GuestDetail type,
  # The value defined here will be used on CRM to check,
  # which type of GuestDetail to create
  # Example:
  # child => ChildDetail
  # person => PersonDetail
  enum guest_type: {
    child: 'ChildDetail',
    person: 'PersonDetail',
  }

  def default_name?
    name.split.first.downcase.eql?('child') rescue false
  end

  def default_count
    name.try(:split).try(:second)
  end
end
