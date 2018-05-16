(->
  window.Lodging or (window.Lodging = {})

  Lodging.init = ->
    Slider.init()
    $('.lodging_type').change ->
      $(this).parents('form').submit()

    $('.lowest-price, .highest-price').click ->
      if $(this).hasClass 'lowest-price'
        $('#order').val('price_asc')
      else if $(this).hasClass 'highest-price'
        $('#order').val('price_desc')
      $(this).parents('form').submit()

).call this
