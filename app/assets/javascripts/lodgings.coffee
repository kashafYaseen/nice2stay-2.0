(->
  window.Lodging or (window.Lodging = {})

  Lodging.init = ->
    Slider.init()
    GuestDropdown.init()
    OwlCarousel.init()
    initDatePicker();
    SidebarCanvas.init('.sidebar-toggle', '.sidebar-offcanvas', '.sidebar-close')

    $('.search-filters .lodging_type, .countries').change ->
      $('#loader').show();
      Rails.fire($('.search-filters .lodgings-filters').get(0), 'submit')

    SortingDropdown.init()

    $('.amenities, .experiences').change ->
      checked = $(".amenities-list input:checked, .experiences-list input:checked").length
      if checked > 0
        $('.more-filters-btn').addClass 'btn-primary'
        $('.more-filters-btn').removeClass 'btn-outline-primary'
        $('.more-filters-btn').text("More Filters .#{checked}")
      else
        $('.more-filters-btn').addClass 'btn-outline-primary'
        $('.more-filters-btn').removeClass 'btn-primary'
        $('.more-filters-btn').text("More Filters")

    $('.submit-filters').click ->
      $('#loader').show();
      Rails.fire($('.search-filters .lodgings-filters').get(0), 'submit')
      $('#more-filters').modal('hide');

    $('#more-filters-btn').click (e) ->
      more_filters_dropdown('toggle')
      e.stopPropagation();

    $('.more-filter-dropdown-menu').click (e) ->
      e.stopPropagation();

    $(document).click ->
      more_filters_dropdown('close')

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
