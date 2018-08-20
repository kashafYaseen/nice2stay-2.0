(->
  window.GuestDropdown or (window.GuestDropdown = {})

  GuestDropdown.init = ->
    $("input[type='number']").InputSpinner();
    update_text()
    $('.guests-dropdown .dropdown-menu').click (e) ->
      e.stopPropagation()

    $('.guests-dropdown').on 'hide.bs.dropdown', (e) ->
      update_text()

    $('.guests-dropdown .submit-filters').click ->
      $(this).dropdown("toggle")

  update_text = ->
    adults = $('.guests-dropdown #adults').val()
    children = $('.guests-dropdown #children').val()
    infants = $('.guests-dropdown #infants').val()
    guests = ""
    if adults then guests += "#{adults} #{if adults > 1 then 'adults' else 'adult'}"
    if children then guests += "#{if adults then ', ' else ' '} #{children} #{if children > 1 then 'children' else 'child'}"
    if infants then guests += "#{if children || adults then ', ' else ' '} #{infants} #{if infants > 1 then 'infants' else 'infant'}"
    if guests
      $('.guests-dropdown .dropdown-toggle .title').text(guests)
      $('.guests-dropdown .dropdown-toggle').addClass 'btn-primary'
      $('.guests-dropdown .dropdown-toggle').removeClass 'btn-outline-primary'

).call this
