require 'rails_helper'

RSpec.describe RoomRate, type: :model do
  describe '#cumulative_price' do
    context 'When Lodging is a OpenGDS Hotel' do
      let(:lodging) { create(:lodging, :reindex, channel: 3) }
      let(:room_type) { create(:room_type, parent_lodging: lodging) }

      context 'When Rate Type = \'Per Stay\'' do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 3, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: ['3']) }
          let(:expected_prices) { [252, 232, 232, 252, 444, 272, 464, 444, 232, 52] }
        end
      end

      context 'When Rate Type = \'Per Person\'' do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 2, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: ['3']) }
          let(:expected_prices) { [252, 444, 444, 464, 656, 484, 676, 656, 868, 52] }
        end
      end

      context "When Rate Type = \'Per Person Per Night\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 0, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [692, 1244, 1244, 1304, 1856, 1364, 1916, 1856, 2468, 92] }
        end
      end

      context "When Rate Type = \'Per Person Per Day\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 4, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [916, 1652, 1652, 1732, 2468, 1812, 2548, 2468, 3284, 116] }
        end
      end

      context "When Rate Type = \'Per Accommodation Per Night\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 1, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [692, 632, 632, 692, 1244, 752, 1304, 1244, 632, 92] }
        end
      end

      context "When Rate Type = \'Per Accommodation Per Day\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 5, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [916, 836, 836, 916, 1652, 996, 1732, 1652, 836, 116] }
        end
      end
    end
  end
end
