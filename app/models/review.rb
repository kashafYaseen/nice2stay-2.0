class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user
  belongs_to :reservation

  validates :stars, :title, presence: true

  translates :title, :suggetion, :description

  delegate :full_name, :email, to: :user, prefix: true
  delegate :slug, to: :lodging, prefix: true

  before_validation :calculate_stars
  after_create :send_review_details

  def calculate_stars
    self.stars = (setting + quality + interior + communication + service) / 5
  end

  private
    def send_review_details
      SendReviewDetailsJob.perform_later self.id
    end
end
