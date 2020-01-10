class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions

  include ImageHelper

  searchkick text_middle: [:title_en, :title_nl]

  validates :title, :description, presence: true
  translates :title, :url, :description, :crm_urls

  default_scope { includes(:translations) }
  scope :home_page, -> { where(collection: true, popular_homepage: true) }
  scope :menu, -> { where(slider: true) }
  scope :spotlight, -> { where(popular_homepage: true, spotlight: true) }
  scope :search_import, -> { home_page }

  def should_index?
    collection && popular_homepage
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
      })
    end
    data
  end
end
