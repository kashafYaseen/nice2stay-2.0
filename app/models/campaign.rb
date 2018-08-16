class Campaign < ApplicationRecord
  has_and_belongs_to_many :regions

  searchkick word_start: [:title]

  validates :title, :description, presence: true
  translates :title, :url, :description

  def search_data
    attributes.merge(
      regions: regions.pluck(:name)
    )
  end
end
