class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user

  delegate :full_name, to: :user, prefix: true, allow_nil: true
end
