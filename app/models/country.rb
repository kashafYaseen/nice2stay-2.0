class Country < ApplicationRecord
  has_many :regions
  has_many :campaigns, through: :regions
  has_many :lodgings, through: :regions
  has_many :custom_texts
  has_and_belongs_to_many :leads

  include ImageHelper

  extend FriendlyId
  friendly_id :name, use: :slugged
  translates :name, :content, :slug, :title, :meta_title
  globalize_accessors

  searchkick text_middle: [:name_en, :name_nl]

  validates :name, presence: true, uniqueness: true

  default_scope { includes(:translations) }
  scope :enabled, -> { where(disable: false).includes(:regions) }
  scope :search_import, -> { enabled }
  scope :ordered, -> { order(boost: :desc) }

  delegate :menu, to: :campaigns, allow_nil: true, prefix: true
  delegate :country_page, to: :lodgings, prefix: true, allow_nil: true

  def should_index?
    !disable
  end

  def search_data
    attributes.merge(
      name_en: name_en,
      name_nl: name_nl,
      title_en: title_en,
      title_nl: title_nl,
      regions: regions.collect(&:name),
      lodging_count: lodgings.published_parents_count,
    )
  end

  def translated_slugs
    translations.pluck(:slug)
  end
end
