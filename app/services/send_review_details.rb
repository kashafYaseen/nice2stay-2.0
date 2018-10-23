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
          customer_email: review.user_email,
          accommodation_slug: review.lodging_slug
        }
      }
    end
end
