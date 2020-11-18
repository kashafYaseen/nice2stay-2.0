class CleaningCost < ApplicationRecord
  belongs_to :lodging, optional: true
  belongs_to :availability, optional: true
  translates :name

  scope :for_guests, -> (guests) { where('guests = ? or guests is null', guests) }
end
