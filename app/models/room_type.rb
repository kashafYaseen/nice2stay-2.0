class RoomType < ApplicationRecord
  belongs_to :parent_lodging, class_name: 'Lodging'
  has_many :child_lodgings, class_name: 'Lodging'
  has_many :rate_plans
  has_many :availabilities

  scope :by_codes, -> (codes) { where(code: codes) }
end
