module BookingExpertHelper
  def get_booking_expert_param(key)
    params[key] || params[:reservation].present? ? params[:reservation][key] : nil
  end

  def get_be_lodging be_availability
    Lodging.find_by(be_category_id: be_availability['relationships']['category']['data']['id'])
  end

  def get_booking_expert_billing(key = 'rent', be_availability)
    return be_availability['attributes']['rent_price'] if key == 'rent'
    be_availability['attributes']['original_price'].to_f - be_availability['attributes']['original_rent_price'].to_f
  end
end
