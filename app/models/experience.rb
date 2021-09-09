class Experience < ApplicationRecord
  has_many :recent_searches, as: :searchable
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_experiences'
  translates :name, :slug
  globalize_accessors

  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick text_middle: [:name_en, :name_nl]

  default_scope { includes(:translations) }

  enum priority: {
    lowest: 0,
    low: 1,
    medium: 2,
    high: 3,
    highest: 4
  }

  def search_data
    attributes.merge(
      name_en: name_en,
      name_nl: name_nl,
      slug_en: slug_en,
      slug_nl: slug_nl,
      lodging_count: lodgings.published_parents_count,
    )
  end

  def translated_slugs
    translations.pluck(:slug)
  end

  def experiences_count_for lodgings
    buckets = lodgings.aggregations['experiences']['buckets']
    count = 0
    buckets.each do |bucket|
      count = bucket['doc_count'] if bucket['key'] == self.id
    end if buckets.present?
    count
  end
end
