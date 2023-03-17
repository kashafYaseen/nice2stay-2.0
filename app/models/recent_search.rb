class RecentSearch < ApplicationRecord
  belongs_to :user
  belongs_to :searchable, polymorphic: true

  scope :upcoming_searches, -> { where("check_in >= :current_date", current_date: Date.today) }
end
