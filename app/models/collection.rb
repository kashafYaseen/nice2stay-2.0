class Collection < ApplicationRecord
  belongs_to :parent, class_name: 'CustomText'
  belongs_to :relative, class_name: 'CustomText'

  validates :relative_id, uniqueness: { scope: :parent_id }
end
