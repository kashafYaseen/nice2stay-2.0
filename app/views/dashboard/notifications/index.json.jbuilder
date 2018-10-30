json.unread_notifications @notifications do |notification|
  json.id notification.id
  json.unread !notification.read_at?
  json.action notification.action
  json.notifiable notification.notifiable
  json.template render partial: "booking", locals: { notification: notification }, formats: [:html]
end

json.notifications @notifications do |notification|
  json.id notification.id
  json.unread !notification.read_at?
  json.action notification.action
  json.notifiable notification.notifiable
  json.template render partial: "booking", locals: { notification: notification }, formats: [:html]
end

json.total_unread @notifications.unread.count
