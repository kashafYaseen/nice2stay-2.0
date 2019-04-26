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

    $(".reservations-details-btn").click (e) ->
      e.stopPropagation()
      $('html, body').animate { scrollTop: $('#infobox').offset().top - 100 }, 'slow'

    $(".question-details-btn").click (e) ->
      e.stopPropagation()
      $('html, body').animate { scrollTop: $('#questions').offset().top - 100 }, 'slow'

    $(".location-details-btn").click (e) ->
      e.stopPropagation()
      $('html, body').animate { scrollTop: $('#location-container').offset().top - 100 }, 'slow'

  set_top_position = ->
    $('.lodgings-list').css("margin-top", "#{$('.fixed-filters').height()-10}px");
    $('#map').css("top", "#{$('.fixed-filters').height()-10}px");

).call this
