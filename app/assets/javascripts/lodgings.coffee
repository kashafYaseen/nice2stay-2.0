(->
  window.Lodging or (window.Lodging = {})

  Lodging.init = ->
    Slider.init()
    GuestDropdown.init()
    OwlCarousel.init()
    initDatePicker();
    SidebarCanvas.init('.sidebar-toggle', '.sidebar-offcanvas', '.sidebar-close')
    SortingDropdown.init()
    Filters.init()

    $('.show-all-filters').click (e) ->
      e.stopPropagation()
      if $(this).text().includes("show all")
        $($(this).data('target')).removeClass 'filters-show-less'
        $(this).text("show less #{$(this).data('name')}")
        $("#{$(this).data('target')}-icon").text('keyboard_arrow_up')
      else
        $($(this).data('target')).addClass 'filters-show-less'
        $(this).text("show all #{$(this).data('name')}")
        $("#{$(this).data('target')}-icon").text('keyboard_arrow_down')

  Lodging.child_form = ->
    $('.navbar.navbar-sticky').css('position', 'relative');
    $('.navbar.navbar-sticky + *').css('margin-top', '0');

    $('.btn-booking').click ->
      if $(this).data('form-id')
        Rails.fire($($(this).data('form-id')).get(0), 'submit')

  Lodging.highlight_menu = ->
    $('.widget-tags .tag').click (e) ->
      e.stopPropagation()

    $(window).scroll ->
      $('.target-section').each ->
        if $(window).scrollTop() >= $(this).position().top - $('.navbar').height()
          $('.widget-tags .tag').removeClass 'active'
          $("a[href='##{$(this).attr('id')}']").addClass 'active'

  Lodging.read_more = ->
    $('.btn-read-more').click ->
      $target = $($(this).data('target'))
      if $(this).text() == "Read more"
        $target.html($(this).data('actual'))
        $(this).text('Show less')
      else
        $target.html($(this).data('truncated'))
        $(this).text('Read more')

  more_filters_dropdown = (option) ->
    if option == 'close'
      $('.more-filter-dropdown-menu, .more-filter-dropdown').removeClass 'show'
    else
      $('.more-filter-dropdown-menu, .more-filter-dropdown').toggleClass 'show'

    checked = $('.more-filter-dropdown input:checkbox:checked')
    if checked.length == 0
      $('#more-filters-btn').val('More Filters')
    else
      $('#more-filters-btn').val("#{checked.length}. Filters")

).call this
