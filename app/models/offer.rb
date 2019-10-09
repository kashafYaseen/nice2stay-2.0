class Offer < ApplicationRecord
  belongs_to :lead
  has_many :offer_lodgings
  has_many :lodgings, through: :offer_lodgings
end
