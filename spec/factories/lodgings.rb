FactoryBot.define do
  factory :lodging do
    lodging_type { 1 }
    region { create(:region) }
    name { 'OpenGDS Test Hotel' }
    presentation { 1 }
    channel { 3 }

    trait :reindex do
      after(:create) do |lodging, _evaluator|
        lodging.reindex(refresh: true)
      end
    end
  end
end
