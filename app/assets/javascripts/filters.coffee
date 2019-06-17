(->
  window.Filters or (window.Filters = {})

  Filters.init = ->
    updated_amenities()
    Filters.update_prices()

    $('.layout-dropdown-menu .dropdown-item').click ->
      Filters.switch_view($(this).prop('class'))

    $('.more-filters-btn').click ->
      $('#more-filters').modal('toggle')
      $('.modal-backdrop').css('z-index', 1);

    $('.amenities, .countries').change ->
      updated_amenities()

    $('.discounts').change ->
      Filters.update_prices()
      Filters.submit()

    $('.submit-filters').click ->
      Url.update("");
      Filters.submit()
      $('#more-filters').modal('hide');

    $('#filters-container .lodging_type, #filters-container .experiences, #filters-container .amenities-hot').change ->
      Url.update("");
      Filters.submit()

  Filters.submit = ->
    $('#loader').show()
    Rails.fire($('#filters-container .lodgings-filters').get(0), 'submit')

  updated_amenities = ->
    if $('.countries-list').css('display') == 'none'
      checked = $(".amenities-list input:checked").length
      $('.countries:checked').prop('checked', false)
    else
      checked = $(".amenities-list input:checked, .countries-list input:checked").length

    title = $('.more-filters-btn').data('title')
    if checked > 0
      $('.more-filters-btn').addClass 'btn-primary'
      $('.more-filters-btn').removeClass 'btn-outline-primary'
      $('.more-filters-btn').text("#{title} .#{checked}")
    else
      $('.more-filters-btn').addClass 'btn-outline-primary'
      $('.more-filters-btn').removeClass 'btn-primary'
      $('.more-filters-btn').text(title)

  Filters.update_prices = ->
    if $('.price-range-slider #min_price').val() == "0" && $('.price-range-slider #max_price').val() == "1500" && $('.discounts:checked').length == 0
      $('#dropdownMenuButton4').removeClass 'btn-primary'
      $('#dropdownMenuButton4').addClass 'btn-outline-primary'
    else
      $('#dropdownMenuButton4').addClass 'btn-primary'
      $('#dropdownMenuButton4').removeClass 'btn-outline-primary'

  Filters.switch_view = (layout) ->
    if layout.includes('list-view') || layout.includes 'List View'
      $('#lodgings-container').removeClass 'col-md-6'
      $('#lodgings-container').removeClass 'd-none'
      $('#lodgings-container').addClass 'col-md-10'
      $('#map-container').removeClass 'd-sm-block'
      $('#map-container').removeClass 'col-md-10'
      $('#layout_view').val('List View')
      $('.layout-dropdown .dropdown-toggle .title').text('List View')
      $('#pagination-container').addClass 'd-none'
      Url.update("");
    else if layout.includes('list-and-map') || layout.includes 'List & Map'
      $('#lodgings-container').addClass 'col-md-6'
      $('#lodgings-container').removeClass 'col-md-10'
      $('#lodgings-container').removeClass 'd-none'
      $('#map-container').removeClass 'col-md-10'
      $('#map-container').addClass 'd-none d-sm-block col-md-4'
      $('#layout_view').val('List & Map')
      $('.layout-dropdown .dropdown-toggle .title').text('List & Map')
      $('#pagination-container').addClass 'd-none'
      map.remove()
      Map.init()
      Url.update("");
    else if layout.includes('map-view') || layout.includes 'Map View'
      $('#lodgings-container').addClass 'd-none'
      $('#map-container').removeClass 'col-md-4 d-none'
      $('#map-container').addClass 'col-md-10 d-sm-block'
      $('#layout_view').val('Map View')
      $('.layout-dropdown .dropdown-toggle .title').text('Map View')
      $('#pagination-container').removeClass 'd-none'
      map.remove()
      Map.init()
      Url.update("");

).call this
