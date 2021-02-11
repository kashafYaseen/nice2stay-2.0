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

  shared_context 'price calculation' do
    def price_calculation_without_extra_beds(params, expected_price)
      room_rate.cumulative_price params
      expect(room_rate.calculated_price).to eq(expected_price)
    end

    def price_with_extra_bed_rate(params, expected_price)
      room_rate.extra_bed_rate = 40
      room_rate.cumulative_price params
      expect(room_rate.calculated_price).to eq(expected_price)
      room_rate.extra_bed_rate = nil
    end
  end

  context 'And Single Rate Type = \'Single Supplement\'' do
    include_context 'price calculation'

    it 'should return price for only 1 adult' do
      price_calculation_without_extra_beds params, expected_prices[0]
    end

    it 'should return price for 1 adult and 1 child' do
      price_calculation_without_extra_beds params.merge(children: 1), expected_prices[1]
    end

    it 'should return price for 1 adult and 1 infant' do
      price_calculation_without_extra_beds params.merge(infants: 1), expected_prices[2]
    end

    context 'And Extra Beds are used' do
      context 'And Extra Bed Rate is Blank' do
        it 'should return price for 2 adult and 1 child' do
          price_calculation_without_extra_beds params.merge(adults: 2, children: 1), expected_prices[3]
        end

        it 'should return price for 2 adults and 1 infant' do
          price_calculation_without_extra_beds params.merge(adults: 2, infants: 1), expected_prices[4]
        end

        it 'should return price for 2 adults and 2 children' do
          price_calculation_without_extra_beds params.merge(adults: 2, children: 2), expected_prices[5]
        end

        it 'should return price for 2 adults and 1 child and 1 infant' do
          price_calculation_without_extra_beds params.merge(adults: 2, children: 1, infants: 1), expected_prices[6]
        end

        it 'should return price for 1 adult and 1 child and 1 infant' do
          price_calculation_without_extra_beds params.merge(children: 1, infants: 1), expected_prices[7]
        end

        it 'should return price for 4 adults' do
          price_calculation_without_extra_beds params.merge(adults: 4), expected_prices[8]
        end
      end

      context 'And Extra Bed Rate is Present' do
        it 'should return price for 2 adults and 1 child' do
          price_with_extra_bed_rate params.merge(adults: 2, children: 1), expected_prices[9]
        end

        it 'should return price for 2 adults and 1 infant' do
          price_with_extra_bed_rate params.merge(adults: 2, infants: 1), expected_prices[10]
        end

        it 'should return price for 2 adults and 2 children' do
          price_with_extra_bed_rate params.merge(adults: 2, children: 2), expected_prices[11]
        end

        it 'should return price for 2 adults and 1 child and 1 infant' do
          price_with_extra_bed_rate params.merge(adults: 2, children: 1, infants: 1), expected_prices[12]
        end

        it 'should return price for 1 adult and 1 child and 1 infant' do
          price_with_extra_bed_rate params.merge(children: 1, infants: 1), expected_prices[13]
        end

        it 'should return price for 4 adults' do
          price_with_extra_bed_rate params.merge(adults: 4), expected_prices[14]
        end
      end
    end
  end

  context 'And Single Rate Type = \'Single Rate\'' do
    include_context 'price calculation'

    it 'should return price for only 1 adult' do
      rate_plan.open_gds_single_rate_type = 1
      price_calculation_without_extra_beds params, expected_prices[15]
    end
  end
end
