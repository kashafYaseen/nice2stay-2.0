class TripMember < ApplicationRecord
  belongs_to :user
  belongs_to :trip

  scope :admins, -> { where(admin: true) }

  delegate :full_name, :email, :invited_by, :invitation_status, to: :user, prefix: true, allow_nil: true
end
