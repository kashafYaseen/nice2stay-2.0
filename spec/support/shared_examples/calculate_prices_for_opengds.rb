RSpec.shared_examples 'Calculate Prices For Opengds' do
  let(:params) do
    {
      check_in: Date.today.to_s,
      check_out: (Date.today + 3.days).to_s,
      adults: 1,
      children: 0,
      infants: 0
    }
  end

  context 'And Single Rate Type = \'Single Supplement\'' do
    it 'should return price for only 1 adult' do
      room_rate.cumulative_price(params)
      expect(room_rate.calculated_price).to eq(expected_prices[0])
    end

    it 'should return price for 1 adult and 1 child' do
      room_rate.cumulative_price(params.merge(children: 1))
      expect(room_rate.calculated_price).to eq(expected_prices[1])
    end

    it 'should return price for 1 adult and 1 infant' do
      room_rate.cumulative_price(params.merge(infants: 1))
      expect(room_rate.calculated_price).to eq(expected_prices[2])
    end

    context 'And Extra Beds are used' do
      it 'should return price for 2 adult and 1 child' do
        room_rate.cumulative_price(params.merge(adults: 2, children: 1))
        expect(room_rate.calculated_price).to eq(expected_prices[3])
      end

      it 'should return price for 2 adult and 1 infant' do
        room_rate.cumulative_price(params.merge(adults: 2, infants: 1))
        expect(room_rate.calculated_price).to eq(expected_prices[4])
      end

      it 'should return price for 2 adult and 2 children' do
        room_rate.cumulative_price(params.merge(adults: 2, children: 2))
        expect(room_rate.calculated_price).to eq(expected_prices[5])
      end

      it 'should return price for 2 adult and 1 child and 1 infant' do
        room_rate.cumulative_price(params.merge(adults: 2, children: 1, infants: 1))
        expect(room_rate.calculated_price).to eq(expected_prices[6])
      end

      it 'should return price for 1 adult and 1 child and 1 infant' do
        room_rate.cumulative_price(params.merge(children: 1, infants: 1))
        expect(room_rate.calculated_price).to eq(expected_prices[7])
      end

      it 'should return price for 4 adults' do
        room_rate.cumulative_price(params.merge(adults: 4))
        expect(room_rate.calculated_price).to eq(expected_prices[8])
      end
    end
  end

  context 'And Single Rate Type = \'Single Rate\'' do
    it 'should return price for only 1 adult' do
      rate_plan.open_gds_single_rate_type = 1
      room_rate.cumulative_price(params)
      expect(room_rate.calculated_price).to eq(expected_prices[9])
    end
  end
end
