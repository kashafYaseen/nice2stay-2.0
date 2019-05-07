class Review < ApplicationRecord
  belongs_to :lodging
  belongs_to :user
  belongs_to :reservation

  has_many_attached :photos

  translates :title, :suggetion, :description

  attr_accessor :skip_data_posting

  scope :published, -> { where(published: true) }
  scope :desc, -> { order('created_at DESC') }
  scope :homepage, -> { published.limit(50).desc }
  scope :rating_sum, -> (type) { uniq.pluck(type).sum.round(2) }
  scope :ratings_average, -> { (RATING_TYPE.sum { |type| rating_sum(type) } / (uniq.count.to_f * 5)).round(2) }

  delegate :full_name, :email, to: :user, prefix: true
  delegate :slug, to: :lodging, prefix: true
  delegate :check_in, :booking_id, to: :reservation, allow_nil: true

  after_commit :update_ratings
  after_create :send_review_details

  RATING_TYPE = [:quality, :interior, :service, :setting, :communication]

  def average_stars
    return stars if stars.present?
    update_column :stars, (RATING_TYPE.sum { |type| send(type) } / 5)
    stars
  end

  def photo_urls
    photos.collect(&:service_url) if photos.attached? && Rails.env.production?
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
