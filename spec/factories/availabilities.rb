FactoryBot.define do
  factory :availability do
    rr_booking_limit { 10 }

    factory :availability_with_prices do
      transient do
        min_stay { (1..3).map(&:to_s) }
        amount { 10 }
        multiple_checkin_days { %w[monday tuesday wednesday thursday friday saturday sunday] }
        open_gds_single_rate { nil }
      end

      after(:create) do |availability, _evaluator|
        create(:price, amount: amount, minimum_stay: min_stay, open_gds_single_rate: open_gds_single_rate, multiple_checkin_days: multiple_checkin_days, availability: availability)
      end
    end
  end
end
