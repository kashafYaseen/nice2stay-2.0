module DashboardHelper
  def active_class(path)
    "active" if current_page?(path)
  end

  def reservations_count
    current_user.reservations_requests.count
  end

  def vouchers_count
    current_user.vouchers.count
  end
end
