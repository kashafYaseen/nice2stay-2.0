class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user

  delegate :full_name, :email, to: :user, prefix: true
  delegate :slug, to: :lodging, prefix: true

  after_create :send_review_details

  private
    def send_review_details
      SendReviewDetailsJob.perform_later self.id
    end
end
