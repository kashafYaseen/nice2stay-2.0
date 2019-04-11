class SendAhoyVisitDetailsJob < ApplicationJob
  queue_as :default

  def perform(visit_id)
    SendAhoyVisitDetails.call(Ahoy::Visit.find_by(id: visit_id))
  end
end
