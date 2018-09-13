class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions

  include ImageHelper

  searchkick word_start: [:title, :description]

  validates :title, :description, presence: true
  translates :title, :url, :description, :crm_urls

  scope :home_page, -> { where(collection: true, popular_homepage: true) }

  def search_data
    attributes.merge(
      regions: regions.pluck(:name)
    )
  end
end
