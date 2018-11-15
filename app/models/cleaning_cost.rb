class CleaningCost < ApplicationRecord
  belongs_to :lodging
  translates :name
end
