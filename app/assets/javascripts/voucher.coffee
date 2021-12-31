(->
  window.Voucher or (window.Voucher = {})

  Voucher.init = ->
    show_message_area($('#voucher_send_by_post'))
    $('#voucher_send_by_post').change ->
      show_message_area($(this))

  show_message_area = (checkbox) ->
    if(checkbox.prop('checked'))
      $('.message-container').removeClass 'd-none'
    else
      $('.message-container').addClass 'd-none'

).call this
