class CleaningCost < ApplicationRecord
  belongs_to :lodging
  belongs_to :rate_plan, optional: true
  translates :name

  scope :for_guests, -> (guests) { where('guests = ? or guests is null', guests) }
end
