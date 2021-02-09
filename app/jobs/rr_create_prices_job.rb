class RrCreatePricesJob < ApplicationJob
  queue_as :rr_prices_queue

  def perform(hotel_id:, room_type_codes:, rate_plan_codes:, rr_prices:)
    RoomRaccoons::CreatePrices.call(
      hotel_id: hotel_id,
      room_type_codes: room_type_codes,
      rate_plan_codes: rate_plan_codes,
      rr_prices: rr_prices
    )
  end
end
