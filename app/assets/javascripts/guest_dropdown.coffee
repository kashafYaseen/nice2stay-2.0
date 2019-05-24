(->
  window.GuestDropdown or (window.GuestDropdown = {})

  GuestDropdown.init = ->
    $('.types-dropdown .dropdown-menu').click (e) ->
      e.stopPropagation()

    $('.types-dropdown').on 'hide.bs.dropdown', (e) ->
      update_types_text()

    $('.types-dropdown .submit-filters').click ->
      $(this).dropdown("toggle")

  update_text = (dropdowns) ->
    for dropdown in dropdowns
      adults = $(dropdown).children().find('.adults').val()
      children = $(dropdown).children().find('.children').val()
      infants = $(dropdown).children().find('.infants').val()
      guests = ""
      if adults then guests += "#{adults} #{if adults > 1 then 'adults' else 'adult'}"
      if children then guests += "#{if adults then ', ' else ' '} #{children} #{if children > 1 then 'children' else 'child'}"
      if infants then guests += "#{if children || adults then ', ' else ' '} #{infants} #{if infants > 1 then 'infants' else 'infant'}"
      if guests
        $(dropdown).children().find('.title').text(guests)

  update_types_text = ->
    text = ""
    text += " Villa" if $('#lodging_type_villa').is(":checked")
    text += " BnB" if $('#lodging_type_bnb').is(":checked")
    text += " Apartment" if $('#lodging_type_apartment').is(":checked")
    if text
      $('.types-dropdown .dropdown-toggle .title').text(text)
      $('.types-dropdown .dropdown-toggle').addClass 'btn-primary'
      $('.types-dropdown .dropdown-toggle').removeClass 'btn-outline-primary'
).call this
