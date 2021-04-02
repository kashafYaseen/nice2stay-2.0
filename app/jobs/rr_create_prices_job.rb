class RrCreatePricesJob < ApplicationJob
  queue_as :rr_prices_queue

  def perform(hotel_id:, lodging_ids:, rate_plan_ids:, rr_prices:)
    PgLock.new(name: 'room_raccoon', attempts: 30, attempt_interval: 40, ttl: false).lock do
      RoomRaccoons::CreatePrices.call(
        hotel_id: hotel_id,
        lodging_ids: lodging_ids,
        rate_plan_ids: rate_plan_ids,
        rr_prices: rr_prices
      )
    end
  end
end
