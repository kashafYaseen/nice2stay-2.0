(->
  window.Review or (window.Review = {})

  Review.init = ->
    $('.published').change ->
      $('.published:checked').not(this).prop 'checked', false

).call this
