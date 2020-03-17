class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions

  include ImageHelper

  searchkick text_middle: [:title_en, :title_nl]

  validates :title, :description, presence: true
  translates :title, :url, :description, :crm_urls
  globalize_accessors

  default_scope { includes(:translations) }
  scope :home_page, -> { where(collection: true, popular_homepage: true) }
  scope :menu, -> { where(slider: true) }
  scope :spotlight, -> { where(popular_homepage: true, spotlight: true) }
  scope :search_import, -> { home_page }

  def should_index?
    collection && popular_homepage
  end

  def search_data
    attributes.merge(
      title_en: title_en,
      title_nl: title_nl,
      regions: regions.collect(&:name)
    )
  end
end
