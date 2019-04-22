class Place < ApplicationRecord
  belongs_to :country
  belongs_to :region
  belongs_to :place_category

  extend FriendlyId
  friendly_id :name, use: :slugged

  translates :details, :description, :name, :slug
end
