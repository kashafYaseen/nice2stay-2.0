require 'rails_helper'

RSpec.describe RoomRate, type: :model do
  describe '#cumulative_price' do
    context 'When Lodging is a OpenGDS Hotel' do
      let(:region) { create(:region) }
      let(:parent_lodging) { create(:lodging, :reindex, channel: 3, region_id: region.id) }
      let(:child_lodging) { create(:lodging, :reindex, channel: 3, name: 'Fabulous Room', description: 'Fabulous Room', parent_id: parent_lodging.id, region_id: region.id) }

      context 'When Rate Type = \'Per Stay\'' do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 3, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: ['3']) }
          let(:expected_prices) { [252, 232, 252, 252, 272, 232, 252, 252, 272, 312, 52] }
        end
      end

      context 'When Rate Type = \'Per Person\'' do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 2, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: ['3']) }
          let(:expected_prices) { [252, 444, 464, 464, 484, 868, 464, 464, 484, 524, 52] }
        end
      end

      context "When Rate Type = \'Per Person Per Night\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 0, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [692, 1244, 1304, 1304, 1364, 2468, 1304, 1304, 1364, 1484, 92] }
        end
      end

      context "When Rate Type = \'Per Person Per Day\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 4, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [916, 1652, 1732, 1732, 1812, 3284, 1732, 1732, 1812, 1972, 116] }
        end
      end

      context "When Rate Type = \'Per Accommodation Per Night\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 1, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [692, 632, 692, 692, 752, 632, 692, 692, 752, 872, 92] }
        end
      end

      context "When Rate Type = \'Per Accommodation Per Day\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 5, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [916, 836, 916, 916, 996, 836, 916, 916, 996, 1156, 116] }
        end
      end
    end
  end
end
