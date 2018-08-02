(->
  window.Cart or (window.Cart = {})

  Cart.init = ->
    show_password_fields($('#create_account'))
    $('#create_account').change ->
      show_password_fields($(this))

  show_password_fields = (checkbox) ->
    if(checkbox.prop("checked"))
      $('.password-fields').removeClass 'd-none'
    else
      $('.password-fields').addClass 'd-none'

).call this
