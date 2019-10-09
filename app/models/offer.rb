class Offer < ApplicationRecord
  belongs_to :lead
  has_many :offer_lodgings
  has_many :lodgings, through: :offer_lodgings

  accepts_nested_attributes_for :offer_lodgings
end
