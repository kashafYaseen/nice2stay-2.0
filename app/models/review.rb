class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user
  belongs_to :reservation

  validates :title, presence: true

  translates :title, :suggetion, :description

  attr_accessor :skip_data_posting

  scope :desc, -> { joins(:reservation).order('reservations.check_in DESC') }
  scope :homepage, -> { limit(50).desc }
  scope :rating_sum, -> (type) { uniq.pluck(type).sum.round(2) }
  scope :ratings_average, -> { (RATING_TYPE.sum { |type| rating_sum(type) } / (uniq.count.to_f * 5)).round(2) }

  delegate :full_name, :email, to: :user, prefix: true
  delegate :slug, to: :lodging, prefix: true
  delegate :check_in, to: :reservation, allow_nil: true

  after_commit :update_ratings
  after_create :send_review_details

  RATING_TYPE = [:quality, :interior, :service, :setting, :communication]

  def average_stars
    return stars if stars.present?
    update_column :stars, (RATING_TYPE.sum { |type| send(type) } / 5)
    stars
  end

  private
    def update_ratings
      return unless lodging.present?
      lodging.update_ratings
      lodging.parent.update_ratings if lodging.parent.present?
    end

    def send_review_details
      SendReviewDetailsJob.perform_later(self.id) unless self.skip_data_posting
    end
end
