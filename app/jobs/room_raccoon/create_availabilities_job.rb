class RoomRaccoon::CreateAvailabilitiesJob < ApplicationJob
  queue_as :default

  def perform(hotel_id:, lodging_ids:, rr_availabilities:)
    PgLock.new(name: 'room_raccoon', attempts: 30, attempt_interval: 40, ttl: false).lock do
      RoomRaccoons::CreateAvailabilities.call(hotel_id: hotel_id, lodging_ids: lodging_ids, rr_availabilities: rr_availabilities)
    end
  end
end
