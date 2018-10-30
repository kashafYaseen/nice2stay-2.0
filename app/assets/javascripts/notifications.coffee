(->
  window.Notification or (window.Notification = {})

  Notification.init = ->
    $('.toolbar-notifications').on 'click', mark_as_read

    $.ajax
      url: $('#notifications').data('index-url');
      type: 'GET'
      dataType: 'JSON'
      success: render_notification

  render_notification = (data) ->
    notifications = $.map data.unread_notifications, (notification) ->
      notification.template

    $('#notifications-body').html(notifications)
    $('.unread-notifications-count').text(data.total_unread)

  mark_as_read = ->
    if $('.unread-notifications-count').text() > 0
      $.ajax
        url: $('#notifications').data('read-url');
        dataType: 'JSON'
        method: 'GET'
        success: ->
          $('.unread-notifications-count').text(0)
    else if !$('.toolbar-notifications').hasClass 'open'
      $('.notification-item').removeClass 'text-bold'

).call this
