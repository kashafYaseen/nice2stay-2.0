class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user
end
