class RrCreateAvailabilitiesJob < ApplicationJob
  queue_as :default

  def perform(hotel_id:, room_type_codes:, rr_availabilities:)
    PgLock.new(name: 'room_raccoon', attempts: 10, attempt_interval: 60).lock do
      RoomRaccoons::CreateAvailabilities.call(hotel_id: hotel_id, room_type_codes: room_type_codes, rr_availabilities: rr_availabilities)
    end
  end
end
