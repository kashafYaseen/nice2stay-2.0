FactoryBot.define do
  factory :availability do
    # booking_limit { 10 }

    factory :availability_with_prices do
      transient do
        amount { 10 }
        multiple_checkin_days { %w[monday tuesday wednesday thursday friday saturday sunday] }
        open_gds_single_rate { nil }
      end

      after(:create) do |availability, evaluator|
        create(
          :price,
          amount: evaluator.amount,
          minimum_stay: availability.minimum_stay,
          open_gds_single_rate: evaluator.open_gds_single_rate,
          multiple_checkin_days: evaluator.multiple_checkin_days,
          availability: availability
        )
      end
    end
  end
end
