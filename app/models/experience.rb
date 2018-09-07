class Experience < ApplicationRecord
  has_and_belongs_to_many :lodgings
  translates :name, :slug
end
