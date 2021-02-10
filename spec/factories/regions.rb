FactoryBot.define do
  factory :region do
    name { 'languedoc-roussillon | midi-pyreneeën' }
    country { create(:country) }

    trait :reindex do
      after(:create) do |region, _evaluator|
        region.reindex(refresh: true)
      end
    end
  end
end
