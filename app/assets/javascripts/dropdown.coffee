(->
  window.Dropdown or (window.Dropdown = {})

  Dropdown.init = ->
    highlight_on_selection()
    $('.types-dropdown .dropdown-menu, .amenities-dropdown .dropdown-menu, .experiences-dropdown .dropdown-menu').click (e) ->
      e.stopPropagation()
      highlight_on_selection()

    $('.types-dropdown, .amenities-dropdown, .experiences-dropdown').on 'hide.bs.dropdown', (e) ->
      highlight_on_selection()

    $('.types-dropdown .submit-filters').click ->
      $(this).dropdown("toggle")

  highlight_on_selection = ->
    if $('.types-dropdown input').is(":checked")
      highlight('.types-dropdown .dropdown-toggle')

    if $('.amenities-dropdown input').is(":checked")
      highlight('.amenities-dropdown .dropdown-toggle')

    if $('.experiences-dropdown input').is(":checked")
      highlight('.experiences-dropdown .dropdown-toggle')

    if $('#min_price').val() > 0 || $('#max_price').val() < 1500
      $('.price-range-dropdown .dropdown-toggle').text "€#{$('#min_price').val()} - €#{$('#max_price').val()}"
      highlight('.price-range-dropdown .dropdown-toggle')
    else if $('.price-range-dropdown input').is(":checked")
      highlight('.price-range-dropdown .dropdown-toggle')

    if $('.realtime-dropdown input').is(":checked")
      highlight('.realtime-dropdown .dropdown-toggle')

    if $('.flexible-dropdown input').is(":checked")
      highlight('.flexible-dropdown .dropdown-toggle')

  highlight = (element) ->
    $(element).addClass 'btn-primary'
    $(element).removeClass 'btn-outline-primary'

).call this
