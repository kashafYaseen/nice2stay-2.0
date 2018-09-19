class Country < ApplicationRecord
  has_many :regions
  has_many :campaigns, through: :regions
  has_and_belongs_to_many :leads

  include ImageHelper

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :content, :slug, :title, :meta_title

  searchkick word_start: [:name, :title]

  validates :name, presence: true, uniqueness: true

  scope :enabled, -> { where(disable: false) }

  delegate :menu, to: :campaigns, allow_nil: true, prefix: true
end
