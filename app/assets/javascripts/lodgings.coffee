(->
  window.Lodging or (window.Lodging = {})

  Lodging.init = ->
    Slider.init()
    GuestDropdown.init()
    OwlCarousel.init()
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

  Lodging.calculate_price = ->
    ids = $('.lodgings-list-json').map(-> JSON.parse @dataset.ids).get()
    url = $('.lodging-container').data('cumulative-url')
    params = "ids=#{ids}&"
    params += "check_in=#{$('.lodgings-filters .check-in').val()}"
    params += "&check_out=#{$('.lodgings-filters .check-out').val()}"
    params += "&adults=#{$('#adults').val()}"
    params += "&children=#{$('#children').val()}"
    params += "&infants=#{$('#infants').val()}"

    $.ajax
      url: "#{url}?#{params}"
      type: 'GET'
      success: (data) ->
        return

  Lodging.child_form = ->
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
    if $('#description-container .btn-read-more').is(":hidden")
      $btn = $('#description-container .btn-read-more')
      $($($btn).data('target')).html($($btn).data('actual'))

    $('.btn-gallery-container').click ->
      if $('#gallery-container').hasClass 'gallery-container-minimized'
        $(this).text('Show Less')
        $('#gallery-container').removeClass 'gallery-container-minimized'
      else
        $(this).text('Show All')
        $('#gallery-container').addClass 'gallery-container-minimized'

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
