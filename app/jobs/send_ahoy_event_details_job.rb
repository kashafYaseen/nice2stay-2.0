class SendAhoyEventDetailsJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    SendAhoyEventDetails.call(Ahoy::Event.find_by(id: event_id))
  end
end
