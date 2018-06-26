class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user

  delegate :full_name, :email, to: :user, prefix: true
  delegate :slug, to: :lodging, prefix: true
end
