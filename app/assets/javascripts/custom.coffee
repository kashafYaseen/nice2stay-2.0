(->
  window.Custom or (window.Custom = {})

  Custom.init = ->
    toolbar_toggle = $('.toolbar-toggle')
    toolbar_dropdown = $('.toolbar-dropdown')
    toolbar_section = $('.toolbar-section')
    mobile_menu = $('.slideable-menu .menu')

    resize_campaigs()
    $(window).resize ->
      resize_campaigs()

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

    $(window).scroll ->
      for scrol_link in $('.scroll-to-btn')
        if isScrolledIntoView $($(scrol_link).data('target'))
          $(scrol_link).addClass 'active'
        else
          $(scrol_link).removeClass 'active'

    $(".scroll-to-btn").click (e) ->
      e.stopPropagation()
      $('html, body').animate { scrollTop: $($(this).data('target')).offset().top - 100 }, 'slow'

    $(".question-details-btn").click (e) ->
      e.stopPropagation()
      $('html, body').animate { scrollTop: $('#questions').offset().top - 100 }, 'slow'

    $(".location-details-btn").click (e) ->
      e.stopPropagation()
      $('html, body').animate { scrollTop: $('#location-container').offset().top - 100 }, 'slow'


  Custom.ask_for_login = ->
    setTimeout (->
      $('#login-form-modal').modal('show');
    ), 10000

  set_top_position = ->
    $('.lodgings-list').css("margin-top", "#{$('.fixed-filters').height()-10}px");
    $('#map').css("top", "#{$('.fixed-filters').height()-10}px");

  isScrolledIntoView = (elem) ->
    $elem = $(elem)
    if $elem.length > 0
      $window = $(window)
      docViewTop = $window.scrollTop()
      docViewBottom = docViewTop + $window.height()
      elemTop = $elem.offset().top
      elemBottom = elemTop + $elem.height()
      elemBottom <= docViewBottom and elemTop >= docViewTop

  resize_campaigs = ->
    $('.spotlight-campaigns img').css('height', $('.ups-tags div').innerHeight());

).call this
