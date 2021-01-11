class RrCreatePricesJob < ApplicationJob
  queue_as :rr_prices_queue

  def perform(hotel_id, room_type_codes, rate_plan_codes, rr_prices)
    RoomRaccoons::CreatePrices.call(hotel_id, room_type_codes, rate_plan_codes, rr_prices)
  end
end
