(->
  window.GuestCentric or (window.GuestCentric = {})

  GuestCentric.init = ->
    GroupToggle.init();

    $("#new_reservation_modal").submit ->
      $('#loader').show()

).call this
