class Country < ApplicationRecord
  has_many :regions
  has_many :campaigns, through: :regions
  has_and_belongs_to_many :leads

  include ImageHelper

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :content, :slug, :title, :meta_title

  searchkick word_start: [:name_en, :name_nl]

  validates :name, presence: true, uniqueness: true

  default_scope { includes(:translations) }
  scope :enabled, -> { where(disable: false).includes(:regions) }
  scope :search_import, -> { enabled }

  delegate :menu, to: :campaigns, allow_nil: true, prefix: true

  def should_index?
    !disable
  end

  def search_data
    attributes.merge(**associations_search_data, **translations_search_data)
  end

  def associations_search_data
    { regions: regions.pluck(:name) }
  end

  def translations_search_data
    data = {}
    translations.each do |translation|
      data.merge!({
        "title_#{translation.locale}": (translation.title || title),
        "name_#{translation.locale}": (translation.name || name),
      })
    end
    data
  end
end
