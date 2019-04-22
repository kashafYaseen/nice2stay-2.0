class Place < ApplicationRecord
  belongs_to :country
  belongs_to :region

  extend FriendlyId
  friendly_id :name, use: :slugged

  translates :details, :description, :name, :slug
end
