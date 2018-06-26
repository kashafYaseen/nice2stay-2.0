class SendReviewDetailsJob < ApplicationJob
  queue_as :default

  def perform(review_id)
    SendReviewDetails.call Review.find_by(id: review_id)
  end
end
