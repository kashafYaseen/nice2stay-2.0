FactoryBot.define do
  factory :child_rate do
    rate_type { 0 }

    before(:create) do |child_rate, _evaluator|
      child_rate.age_group = [1, 2, 3].include?(child_rate.open_gds_category) ? 1 : 0
    end
  end

  factory :rate_plan do
    code { 'BAR' }
    name { 'Best Available Rate' }
    description { 'Best Available Rate Plan' }
    open_gds_res_fee { 20 }
    open_gds_daily_supplements { { 'Fri' => '4', 'Mon' => '4', 'Sat' => '5', 'Sun' => '5', 'Thu' => '4', 'Tue' => '4', 'Wed' => '4' } }

    factory :rate_plan_with_child_rates_and_rule do
      transient do
        categories { [1] }
        rates { [10] }
        start_date { Date.today }
        end_date { Date.today + 60.days }
        lodging_id { nil }
        open_gds_arrival_days { %w[monday tuesday wednesday thursday friday saturday sunday] }
      end

      after(:create) do |rate_plan, evaluator|
        evaluator.categories.size.times do |index|
          create(:child_rate, open_gds_category: evaluator.categories[index], rate: evaluator.rates[index], rate_plan: rate_plan)
          rate_plan.reload
        end

        create(
          :rule,
          start_date: evaluator.start_date,
          end_date: evaluator.end_date,
          lodging_id: evaluator.lodging_id,
          open_gds_arrival_days: evaluator.open_gds_arrival_days,
          rate_plan: rate_plan
        )
      end
    end
  end
end
