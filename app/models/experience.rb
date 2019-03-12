class Experience < ApplicationRecord
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_experiences'
  translates :name, :slug

  extend FriendlyId
  friendly_id :name, use: :slugged

  def translated_slugs
    translations.pluck(:slug)
  end
end
