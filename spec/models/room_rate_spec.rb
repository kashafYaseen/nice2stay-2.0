require 'rails_helper'

RSpec.describe RoomRate, type: :model do
  describe '#cumulative_price' do
    context 'When Lodging is a OpenGDS Hotel' do
      let(:lodging) { create(:lodging, :reindex, channel: 3) }
      let(:room_type) { create(:room_type, parent_lodging: lodging) }
      let(:params) do
        {
          check_in: Date.today.to_s,
          check_out: (Date.today + 3.days).to_s,
          adults: 1,
          children: 0,
          infants: 0
        }
      end

      context 'When Rate Type = \'Per Stay\'' do
        # no infant rate present
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 3, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }
        let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: ['3']) }

        context 'When Single Rate Type = \'Single Supplement\'' do
          it 'should return price for only 1 adult' do
            room_rate.cumulative_price(params)
            expect(room_rate.calculated_price).to eq(252)
          end

          it 'should return price for 1 adult and 1 child' do
            room_rate.cumulative_price(params.merge(children: 1))
            expect(room_rate.calculated_price).to eq(232)
          end

          context 'When Extra Beds are used' do
            it 'should return price for 2 adult and 1 child' do
              room_rate.cumulative_price(params.merge(adults: 2, children: 1))
              expect(room_rate.calculated_price).to eq(252)
            end

            it 'should return price for 2 adult and 1 infant' do
              room_rate.cumulative_price(params.merge(adults: 2, infants: 1))
              expect(room_rate.calculated_price).to eq(444)
            end

            it 'should return price for 2 adult and 2 children' do
              room_rate.cumulative_price(params.merge(adults: 2, children: 2))
              expect(room_rate.calculated_price).to eq(272)
            end

            it 'should return price for 2 adult and 1 child and 1 infant' do
              room_rate.cumulative_price(params.merge(adults: 2, children: 1, infants: 1))
              expect(room_rate.calculated_price).to eq(464)
            end

            it 'should return price for 1 adult and 1 child and 1 infant' do
              room_rate.cumulative_price(params.merge(children: 1, infants: 1))
              expect(room_rate.calculated_price).to eq(444)
            end

            it 'should return price for 4 adults' do
              room_rate.cumulative_price(params.merge(adults: 4))
              expect(room_rate.calculated_price).to eq(232)
            end
          end
        end

        context 'When Single Rate Type = \'Single Rate\'' do
          it 'should return price for only 1 adult' do
            rate_plan.update(open_gds_single_rate_type: 1)
            room_rate.cumulative_price(params)
            expect(room_rate.calculated_price).to eq(52)
          end
        end
      end

      context 'When Rate Type = \'Per Person\'' do
        let(:rate_plan) { create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 2, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id) }
        let(:room_rate) { create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: ['3']) }

        context 'When Single Rate Type = \'Single Supplement\'' do
          it 'should return price for only 1 adult' do
            room_rate.cumulative_price(params)
            expect(room_rate.calculated_price).to eq(252)
          end

          it 'should return price for 1 adult and 1 child' do
            room_rate.cumulative_price(params.merge(children: 1))
            expect(room_rate.calculated_price).to eq(444)
          end

          it 'should return price for 1 adult and 1 infant' do
            room_rate.cumulative_price(params.merge(infants: 1))
            expect(room_rate.calculated_price).to eq(444)
          end

          context 'When Extra Beds are used' do
            it 'should return price for 2 adult and 1 child' do
              room_rate.cumulative_price(params.merge(adults: 2, children: 1))
              expect(room_rate.calculated_price).to eq(464)
            end

            it 'should return price for 2 adult and 1 infant' do
              room_rate.cumulative_price(params.merge(adults: 2, infants: 1))
              expect(room_rate.calculated_price).to eq(656)
            end

            it 'should return price for 2 adult and 2 children' do
              room_rate.cumulative_price(params.merge(adults: 2, children: 2))
              expect(room_rate.calculated_price).to eq(484)
            end

            it 'should return price for 2 adult and 1 child and 1 infant' do
              room_rate.cumulative_price(params.merge(adults: 2, children: 1, infants: 1))
              expect(room_rate.calculated_price).to eq(676)
            end

            it 'should return price for 1 adult and 1 child and 1 infant' do
              room_rate.cumulative_price(params.merge(children: 1, infants: 1))
              expect(room_rate.calculated_price).to eq(656)
            end

            it 'should return price for 4 adults' do
              room_rate.cumulative_price(params.merge(adults: 4))
              expect(room_rate.calculated_price).to eq(868)
            end
          end
        end

        context 'When Single Rate Type = \'Single Rate\'' do
          it 'should return price for only 1 adult' do
            rate_plan.update(open_gds_single_rate_type: 1)
            room_rate.cumulative_price(params)
            expect(room_rate.calculated_price).to eq(52)
          end
        end
      end
    end
  end
end
