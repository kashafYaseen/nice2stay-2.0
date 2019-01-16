class CleaningCost < ApplicationRecord
  belongs_to :lodging
  translates :name

  scope :for_guests, -> (guests) { where('guests = ? or guests is null', guests) }
end
