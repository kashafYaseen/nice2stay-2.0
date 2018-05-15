(->
  window.Lodging or (window.Lodging = {})

  Lodging.init = ->
    Slider.init()
    $('.lodging_type').change ->
      $(this).parents('form').submit()

).call this
