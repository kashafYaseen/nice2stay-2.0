class SendReviewDetails
  attr_reader :review
  attr_reader :uri

  def self.call(review)
    self.new(review).call
  end

  def initialize(review)
    @review = review
    @uri = URI.parse("#{ENV['CRM_BASE_URL']}/feedbacks")
  end

  def call
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if Rails.env.production?
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = feedback.to_json
    http.request(request)
  end

  private
    def header
      { 'Content-Type': 'application/json' }
    end

    def feedback
      {
        feedback: {
          setting: review.setting,
          quality: review.quality,
          interior: review.interior,
          communication: review.communication,
          service: review.service,
          suggetion: review.suggetion,
          title: review.title,
          review: review.description,
          further_explanation: review.nice2stay_feedback,
          customer_email: review.user_email,
          accommodation_slug: review.lodging_slug,
          pubish_as: pubish_as,
          front_end_id: review.id,
          published: review.published,
          skip_data_posting: true,
          images: review.images.collect(&:url),
          published: review.published,
        },
        booking_id: review.booking_id,
        booking_accommodtion_id: review.reservation_id,
      }
    end

    def pubish_as
      return '0' if !review.client_published?
      return '1' if review.anonymous?
      '2'
    end
end
