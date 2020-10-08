class Experience < ApplicationRecord
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_experiences'
  translates :name, :slug
  globalize_accessors

  extend FriendlyId
  friendly_id :name, use: :slugged

  searchkick text_middle: [:name_en, :name_nl]

  default_scope { includes(:translations) }

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
end
