class Experience < ApplicationRecord
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_experiences'
  translates :name, :slug

  def translated_slugs
    translations.pluck(:slug)
  end
end
