(->
  window.Filters or (window.Filters = {})

  Filters.init = ->
    updated_amenities()
    Filters.update_prices()

    $('#moreFilters, .close-filters-dropdown').click ->
      $('.more-filters-dropdown-menu').toggleClass 'd-none'

    $('.filters-autocomplete').on 'keypress', (e) ->
      if e.which == 13
        $('.lodgings-filters .query').val $(this).val()
        Filters.submit()

    $('.layout-btn').click ->
      Filters.switch_view($(this).prop('class'))

    $('.more-filters-btn').click ->
      $('#more-filters').modal('toggle')
      $('.modal-backdrop').css('z-index', 1);

    $('.amenities, .amenities-hot, .experiences, .discounts').change ->
      updated_amenities()
      Filters.submit()

    $('.submit-filters').click ->
      Url.update("");
      Filters.submit()
      $('#more-filters').modal('hide');

    $('#filters-container .lodging_type, #filters-container .realtime-availability, #filters-container .flexible-arrival').change ->
      Url.update("");
      Filters.submit()

  Filters.submit = ->
    $('#loader').show()
    Rails.fire($('#filters-container .lodgings-filters').get(0), 'submit')

  updated_amenities = ->
    checked = $(".more-filters-dropdown-menu input:checked").length

    if checked > 0
      $('.more-filters-btn').addClass 'btn-primary'
      $('.more-filters-btn').removeClass 'btn-outline-primary'
    else
      $('.more-filters-btn').addClass 'btn-outline-primary'
      $('.more-filters-btn').removeClass 'btn-primary'

  Filters.update_prices = ->
    if $('.price-range-slider #min_price').val() == "0" && $('.price-range-slider #max_price').val() == "1500" && $('.discounts:checked').length == 0
      $('#dropdownMenuButton4').removeClass 'btn-primary'
      $('#dropdownMenuButton4').addClass 'btn-outline-primary'
    else
      $('#dropdownMenuButton4').addClass 'btn-primary'
      $('#dropdownMenuButton4').removeClass 'btn-outline-primary'

  Filters.switch_view = (layout) ->
    $('.layout-btn').removeClass 'text-bold'
    if layout.includes('list-view') || layout.includes 'List View'
      $('#lodgings-container').removeClass 'col-md-5 d-none'
      $('#lodgings-container').addClass 'col-md-10'
      $('#map-container').removeClass 'd-sm-block col-md-12'
      $('#layout_view').val('List View')
      $('.view-dropdown .dropdown-toggle .title').text('GRID')
      $('.list-view').addClass 'text-bold'
      $('#pagination-container').addClass 'd-none'
      $('.lodging-container').addClass 'col-md-6'
      $('.lodging-container').removeClass 'col-md-12'
      Url.update("");
    else if layout.includes('list-and-map') || layout.includes 'List & Map'
      $('#lodgings-container').addClass 'col-md-5'
      $('#lodgings-container').removeClass 'col-md-10 d-none'
      $('#map-container').removeClass 'col-md-12'
      $('#map-container').addClass 'd-none d-sm-block col-lg-5 col-xl-5'
      $('#layout_view').val('List & Map')
      $('.view-dropdown .dropdown-toggle .title').text('GRID & MAP')
      $('.list-and-map').addClass 'text-bold'
      $('#pagination-container').addClass 'd-none'
      $('.lodging-container').addClass 'col-md-12'
      $('.lodging-container').removeClass 'col-md-6'
      map.remove()
      Map.init()
      Url.update("");
    else if layout.includes('map-view') || layout.includes 'Map View'
      $('#lodgings-container').addClass 'd-none'
      $('#map-container').removeClass 'col-lg-5 col-xl-5 d-none'
      $('#map-container').addClass 'col-md-12 d-sm-block'
      $('#layout_view').val('Map View')
      $('.view-dropdown .dropdown-toggle .title').text('LARGE MAP')
      $('.map-view').addClass 'text-bold'
      $('#pagination-container').removeClass 'd-none'
      map.remove()
      Map.init()
      Url.update("");
    else
      $('.list-view').addClass 'text-bold'
      $('#pagination-container, #map-container .secondary-navbar').addClass 'd-none'
      $('#map-container').removeClass 'd-sm-block'

  Filters.remove_pill = ->
    $('.close-filter-pill').click ->
      $elem = $($(this).data('id'))
      if $elem.is(':checkbox')
        $elem.prop('checked', false)
      $(this).parent().remove()
      Filters.submit()

).call this
