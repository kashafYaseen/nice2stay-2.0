class Experience < ApplicationRecord
  has_and_belongs_to_many :lodgings, join_table: 'lodgings_experiences'
  translates :name, :slug
end
