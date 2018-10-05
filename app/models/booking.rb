class Booking < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reservations

  scope :in_cart, -> { where(in_cart: true) }

  accepts_nested_attributes_for :reservations
  accepts_nested_attributes_for :user

  def identifier
    "#{user_identifier}#{created_at.to_i}"
  end

  def user_identifier
    (user.try(:last_name) || 'By Houseowner').split(' ').join('').upcase
  end
end
