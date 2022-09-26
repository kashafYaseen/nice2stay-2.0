class HistoryLodging < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  scope :with_lodgings, -> { includes(:lodging) }
end
