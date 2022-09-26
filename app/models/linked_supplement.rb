class LinkedSupplement < ApplicationRecord
  belongs_to :supplementable, polymorphic: true
  belongs_to :supplement
end
