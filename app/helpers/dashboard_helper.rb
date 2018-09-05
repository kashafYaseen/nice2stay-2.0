module DashboardHelper
  def active_class(path)
    "active" if current_page?(path)
  end

  def reservations_count
    current_user.reservations_requests.count
  end
end
