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
          let(:expected_prices) { [232, 212, 232, 232, 252, 212, 232, 232, 252, 292, 32] }
        end
      end

      context 'When Rate Type = \'Per Person\'' do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 2, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: ['3']) }
          let(:expected_prices) { [232, 424, 444, 444, 464, 848, 444, 444, 464, 504, 32] }
        end
      end

      context "When Rate Type = \'Per Person Per Night\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 0, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [672, 1224, 1284, 1284, 1344, 2448, 1284, 1284, 1344, 1464, 72] }
        end
      end

      context "When Rate Type = \'Per Person Per Day\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 4, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [896, 1632, 1712, 1712, 1792, 3264, 1712, 1712, 1792, 1952, 96] }
        end
      end

      context "When Rate Type = \'Per Accommodation Per Night\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 1, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [672, 612, 672, 672, 732, 612, 672, 672, 732, 852, 72] }
        end
      end

      context "When Rate Type = \'Per Accommodation Per Day\'" do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 5, open_gds_single_rate_type: 0, min_stay: 1, max_stay: 3, categories: [1, 2], rates: [10, 20], parent_lodging_id: parent_lodging.id) }

        include_examples 'Calculate Prices For Opengds' do
          let(:room_rate) { create(:room_rate_with_availabilities, child_lodging: child_lodging, rate_plan: rate_plan, min_stay: %w[1 2 3]) }
          let(:expected_prices) { [896, 816, 896, 896, 976, 816, 896, 896, 976, 1136, 96] }
        end
      end
    end
  end
end
