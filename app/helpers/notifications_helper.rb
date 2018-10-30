module NotificationsHelper
  def unread_class(notification)
    "text-bold" if notification.unread?
  end
end
