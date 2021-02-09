FactoryBot.define do
  factory :child_rate do
    rate_type { 0 }
  end

  factory :rate_plan do
    code { 'BAR' }
    name { 'Best Available Rate' }
    description { 'Best Available Rate Plan' }
    open_gds_res_fee { 20 }

    factory :rate_plan_with_child_rates do
      transient do
        category { [1] }
        age_group { [0] }
        rate { [10] }
        child_rate_count { 1 }
      end

      after(:create) do |rate_plan, _evaluator|
        child_rate_count.times do |index|
          create(:child_rate, open_gds_category: category[index], age_group: age_group[index], rate: rate[index], rate_plan: rate_plan)
          rate_plan.reload
        end
      end
    end
  end
end
