(->
  window.Custom or (window.Custom = {})

  Custom.init = ->
    toolbar_toggle = $('.toolbar-toggle')
    toolbar_dropdown = $('.toolbar-dropdown')
    toolbar_section = $('.toolbar-section')
    mobile_menu = $('.slideable-menu .menu')

    close_tool_box = ->
      toolbar_toggle.removeClass 'active'
      toolbar_section.removeClass 'current'

    toolbar_toggle.on 'click', (e) ->
      current_value = $(this).attr('href')
      if $(e.target).is('.active')
        close_tool_box()
        toolbar_dropdown.removeClass 'open'
      else
        toolbar_dropdown.addClass 'open'
        close_tool_box()
        $(this).addClass 'active'
        $(current_value).addClass 'current'
        mobile_menu.attr 'data-height', mobile_menu.height()
      e.preventDefault()

    $('.close-dropdown').on 'click', ->
      toolbar_dropdown.removeClass 'open'
      toolbar_toggle.removeClass 'active'
      toolbar_section.removeClass 'current'

).call this
