class Booking < ApplicationRecord
  belongs_to :user, optional: true
  has_many :reservations

  scope :in_cart, -> { where(in_cart: true) }
  scope :requests, -> { where(in_cart: false) }
  scope :confirmed, -> { requests.where(confirmed: true) }

  accepts_nested_attributes_for :reservations
  accepts_nested_attributes_for :user

  attr_accessor :skip_data_posting

  def identifier
    be_identifier || "#{user_identifier}#{created_at.to_i}"
  end

  def user_identifier
    (user.try(:last_name) || 'By Houseowner').split(' ').join('').upcase
  end

  def have_confirmed_requests?
    reservations.pluck(:request_status).include?('confirmed')
  end
end
