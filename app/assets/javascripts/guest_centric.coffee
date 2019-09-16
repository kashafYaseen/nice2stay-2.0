(->
  window.GuestCentric or (window.GuestCentric = {})

  GuestCentric.init = ->
    GroupToggle.init();
    Rails.fire($('#new_reservation_modal').get(0), 'submit')

    $("#new_reservation_modal").submit ->
      $('#loader').show()

).call this
