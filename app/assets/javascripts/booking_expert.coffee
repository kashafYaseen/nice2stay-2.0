(->
  window.BookingExpert or (window.BookingExpert = {})

  BookingExpert.init = ->
    Rails.fire($('#new_reservation_modal').get(0), 'submit')

    $('.total-rooms').change ->
      $('.rooms').val $(this).val()

    $("#new_reservation_modal").submit ->
      $('#loader').show()

).call this
