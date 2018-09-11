class Country < ApplicationRecord
  has_many :regions

  include ImageHelper

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :content, :slug, :title, :meta_title

  searchkick word_start: [:name, :title]

  validates :name, presence: true, uniqueness: true
end
