module BookingExpertHelper
  def get_booking_expert_param(key)
    params[key] || params[:reservation].present? ? params[:reservation][key] : nil
  end

  def get_be_lodging be_availability
    Lodging.find_by(be_category_id: be_availability['relationships']['category']['data']['id'])
  end
end
