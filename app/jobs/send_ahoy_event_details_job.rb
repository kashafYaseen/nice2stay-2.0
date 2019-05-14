class SendAhoyEventDetailsJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Ahoy::Event.find_by(id: event_id)
    SendAhoyEventDetails.call(event) if event.present?
  end
end
