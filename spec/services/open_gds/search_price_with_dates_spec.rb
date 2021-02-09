require 'rails_helper'

RSpec.describe OpenGds::SearchPriceWithDates do
  describe '.call' do
    it 'should return price for Per Stay Rate Type For only 1 adult' do
      lodging = create(:lodging, :reindex)
      room_type = create(:room_type, parent_lodging: lodging)
      rate_plan = create(:rate_plan)
      room_rate = create(:room_rate, room_type: room_type, rate_plan: rate_plan)
      expect(room_type.parent_lodging.name).to eq('OpenGDS Test Hotel')
    end
  end
end
