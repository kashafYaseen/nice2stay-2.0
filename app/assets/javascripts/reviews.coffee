(->
  window.Review or (window.Review = {})

  Review.init = ->
    $('.starrr').starrr()

    $('.starrr').on 'starrr:change', (e, value) ->
      $($(this).data('target')).val(value)

    $('.published').change ->
      $('.published:checked').not(this).prop 'checked', false

).call this
