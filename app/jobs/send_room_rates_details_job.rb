class SendRoomRatesDetailsJob < ApplicationJob
  queue_as :default

  def perform(room_rate_ids)
    room_rates = RoomRate.where(id: room_rate_ids).published.includes(:child_lodging, :rate_plan)
    room_rates.each { |room_rate| SendRoomRateDetails.call(room_rate) }
  end
end
