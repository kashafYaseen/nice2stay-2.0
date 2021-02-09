FactoryBot.define do
  factory :country do
    before(:create) do |_country|
      Country.reindex
    end

    name { 'frankrijk' }
    dropdown { true }
    sidebar { true }
    thumbnails { ['https://imagesnice2stayeurope.s3.amazonaws.com/uploads/image/image/12104/thumb_lavender-894919_1920.jpg'] }
    images { ['https://imagesnice2stayeurope.s3.amazonaws.com/uploads/image/image/12104/lavender-894919_1920.jpg'] }
    code { 'FR' }

    trait :reindex do
      after(:create) do |country, _evaluator|
        country.reindex(refresh: true)
      end
    end
  end
end
