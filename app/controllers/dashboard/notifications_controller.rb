class Dashboard::NotificationsController < DashboardController
  def index
    @notifications = current_user.notifications_recent.includes(:notifiable)
  end

  def mark_as_read
    notifications = current_user.notifications.unread
    notifications.update_all(read_at: Time.current)
    render json: { success: true }
  end
end
