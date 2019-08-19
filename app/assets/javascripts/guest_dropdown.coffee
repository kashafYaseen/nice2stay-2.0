(->
  window.TypeDropdown or (window.TypeDropdown = {})

  TypeDropdown.init = ->
    highlight_on_selection()
    $('.types-dropdown .dropdown-menu').click (e) ->
      e.stopPropagation()
      highlight_on_selection()

    $('.types-dropdown').on 'hide.bs.dropdown', (e) ->
      highlight_on_selection()

    $('.types-dropdown .submit-filters').click ->
      $(this).dropdown("toggle")

  highlight_on_selection = ->
    if $('.types-dropdown input').is(":checked")
      $('.types-dropdown .dropdown-toggle').addClass 'btn-primary'
      $('.types-dropdown .dropdown-toggle').removeClass 'btn-outline-primary'

).call this
