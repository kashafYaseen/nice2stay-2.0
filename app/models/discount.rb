class Discount < ApplicationRecord
  belongs_to :lodging
  searchkick

  scope :active, -> { where("valid_to >= ? and publish = ?", Date.today, true) }

  delegate :name, to: :lodging, prefix: true
end
