module GuestCentricHelper
  def get_centric_param(key)
    params[key] || params[:reservation].present? ? params[:reservation][key] : nil
  end
end
