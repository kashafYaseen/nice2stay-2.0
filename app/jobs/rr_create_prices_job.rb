class RrCreatePricesJob < ApplicationJob
  queue_as :rr_prices_queue

  def perform(hotel_id:, room_type_codes:, rate_plan_codes:, rr_prices:)
    PgLock.new(name: 'room_raccoon', attempts: 30, attempt_interval: 40, ttl: false).lock do
      RoomRaccoons::CreatePrices.call(
        hotel_id: hotel_id,
        room_type_codes: room_type_codes,
        rate_plan_codes: rate_plan_codes,
        rr_prices: rr_prices
      )
    end
  end
end
