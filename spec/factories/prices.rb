FactoryBot.define do
  factory :price do
    adults { ['999'] }
    children { ['0'] }
    infants { ['0'] }

    trait :reindex do
      after(:create) do |price, _evaluator|
        price.reindex(refresh: true)
      end
    end
  end
end
