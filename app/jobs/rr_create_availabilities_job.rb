class RrCreateAvailabilitiesJob < ApplicationJob
  queue_as :default

  def perform(hotel_id, room_type_codes, rr_availabilities)
    RoomRaccoons::CreateAvailabilities.call(hotel_id, room_type_codes, rr_availabilities)
  end
end
