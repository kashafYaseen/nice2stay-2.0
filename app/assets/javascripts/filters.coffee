(->
  window.Filters or (window.Filters = {})

  Filters.init = ->
    updated_amenities()
    Filters.update_prices()

    $('#filters-container #switch-views').click ->
      if $(this).text() == 'List View'
        $('#lodgings-container').removeClass 'col-md-6'
        $('#lodgings-container').addClass 'col-md-10'
        $('#map-container').removeClass 'd-sm-block'
        $(this).text('Map View')
        $('#layout_view').val('Map View')
      else
        $('#lodgings-container').addClass 'col-md-6'
        $('#lodgings-container').removeClass 'col-md-10'
        $('#map-container').addClass 'd-sm-block'
        $(this).text('List View')
        $('#layout_view').val('List View')

    $('.more-filters-btn').click ->
      $('#more-filters').modal('toggle')
      $('.modal-backdrop').css('z-index', 1);

    $('.amenities, .countries').change ->
      updated_amenities()

    $('.discounts').change ->
      Filters.update_prices()
      Filters.submit()

    $('.submit-filters').click ->
      Filters.submit()
      $('#more-filters').modal('hide');

    $('#filters-container .lodging_type, #filters-container .experiences, #filters-container .amenities-hot').change ->
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

).call this
