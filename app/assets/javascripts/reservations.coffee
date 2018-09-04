(->
  window.Reservation or (window.Reservation = {})

  Reservation.validate = (values) ->
    url = $('.persisted-data').data('validate-url');
    $.ajax
      url: "#{url}?values=#{values}"
      type: 'GET'
      success: (data) ->
        return

).call this
