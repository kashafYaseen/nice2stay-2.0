class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user
  belongs_to :reservation

  validates :stars, :title, presence: true

  translates :title, :suggetion, :description

  scope :desc, -> { joins(:reservation).order('reservations.check_in DESC') }
  scope :homepage, -> { limit(50).desc }
  scope :rating_sum, -> (type) { uniq.pluck(type).sum.round(2) }
  scope :ratings_average, -> { (RATING_TYPE.sum { |type| rating_sum(type) } / (uniq.count.to_f * 5)).round(2) }

  delegate :full_name, :email, to: :user, prefix: true
  delegate :slug, to: :lodging, prefix: true
  delegate :check_in, to: :reservation, allow_nil: true

  before_validation :calculate_stars
  after_create :send_review_details

  RATING_TYPE = [:quality, :interior, :service, :setting, :communication]

  def calculate_stars
    self.stars = (setting + quality + interior + communication + service) / 5
  end

  private
    def send_review_details
      SendReviewDetailsJob.perform_later self.id
    end
end
