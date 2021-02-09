FactoryBot.define do
  factory :room_rate do
    default_booking_limit { 10 }
    default_rate { 200 }
    default_single_rate { 20 }

    factory :room_rate_with_availabilities do
      transient do
        dates { (Date.today..365.days.from_now).map(&:to_s) }
        min_stay { (1..3).map(&:to_s) }
      end

      after(:create) do |room_rate, _evaluator|
        dates.each do |date|
          create(:availability_with_prices, available_on: date, room_rate: room_rate, rr_minimum_stay: min_stay)
        end
      end
    end
  end
end
