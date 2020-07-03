module BookingExpertHelper
  def get_booking_expert_param(key)
    params[key] || params[:reservation].present? ? params[:reservation][key] : nil
  end
end
