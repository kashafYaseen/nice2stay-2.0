FactoryBot.define do
  factory :lodging do
    lodging_type { 1 }
    name { 'OpenGDS Test Hotel' }
    presentation { 1 }
    channel { 3 }
    extra_beds { 2 }
    extra_beds_for_children_only { false }
    adults { 2 }
    children { 0 }
    infants { 0 }

    trait :reindex do
      after(:create) do |lodging, _evaluator|
        lodging.reindex(refresh: true)
      end
    end
  end
end
