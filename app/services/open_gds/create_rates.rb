class OpenGds::CreateRates
  attr_reader :body

  def initialize(body)
    @body = body
    # @hotel = Lodging.find_by(id: hotel_id)
  end

  def self.call(body)
    self.new(body).call
  end

  def call
    rate = body.first
    hotel =
  end
end
