require 'rails_helper'

RSpec.describe RoomRate, type: :model do
  describe '#cumulative_price' do
    let(:lodging) { create(:lodging, :reindex) }
    let(:room_type) { create(:room_type, parent_lodging: lodging) }
    let(:params) {
      {
        check_in: Date.today.to_s,
        check_out: (Date.today + 3.days).to_s,
        adults: 1,
        children: 0,
        infants: 0
      }
    }

    it 'should return price for only 1 adult for rate plan with Per Stay Rate Type and Single Supplement Single Rate Type' do
      rate_plan = create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 3, open_gds_single_rate_type: 0, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id)
      room_rate = create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: ['3'])
      room_rate.cumulative_price(params)
      expect(room_rate.calculated_price).to eq(252)
    end

    it 'should return price for only 1 adult for rate plan with Per Stay Rate Type and Fixed Rate Single Rate Type' do
      rate_plan = create(:rate_plan_with_child_rates_and_rule, open_gds_rate_type: 3, open_gds_single_rate_type: 1, min_stay: 3, max_stay: 3, categories: [1, 2], rates: [10, 20], lodging_id: lodging.id)
      room_rate = create(:room_rate_with_availabilities, room_type: room_type, rate_plan: rate_plan, min_stay: ['3'])
      room_rate.cumulative_price(params)
      expect(room_rate.calculated_price).to eq(52)
    end
  end
end
