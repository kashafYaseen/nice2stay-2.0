(->
  window.Trip or (window.Trip = {})

  Trip.init = ->
    $('#wishlist .navbar-trip-id').val $('body .trip-id-radio:checked').val()

    $('body').on 'change', '.trip-id-radio', ->
      $('#wishlist .navbar-trip-id').val $(this).val()

).call this
