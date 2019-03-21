(->
  window.Filters or (window.Filters = {})

  Filters.init = ->
    updated_amenities_and_experiences()
    update_lodging_types()
    Filters.update_prices()

    $('.more-filters-btn').click ->
      $('#more-filters').modal('toggle')
      $('.modal-backdrop').css('z-index', 1);

    $('.amenities, .experiences').change ->
      updated_amenities_and_experiences()

    $('.discounts').change ->
      Filters.update_prices()
      Filters.submit()

    $('.countries').change ->
      Filters.submit()

    $('.submit-filters').click ->
      Filters.submit()
      $('#more-filters').modal('hide');

    $('.search-filters .lodging_type').change ->
      update_lodging_types()
      Filters.submit()

  Filters.submit = ->
    $('#loader').show()
    Rails.fire($('.search-filters .lodgings-filters').get(0), 'submit')

  updated_amenities_and_experiences = ->
    checked = $(".amenities-list input:checked, .experiences-list input:checked").length
    if checked > 0
      $('.more-filters-btn').addClass 'btn-primary'
      $('.more-filters-btn').removeClass 'btn-outline-primary'
      $('.more-filters-btn').text("More Filters .#{checked}")
    else
      $('.more-filters-btn').addClass 'btn-outline-primary'
      $('.more-filters-btn').removeClass 'btn-primary'
      $('.more-filters-btn').text("More Filters")

  update_lodging_types = ->
    if $('.lodging-types-list input:checked').length > 0
      $('#dropdownMenuButton3').addClass 'btn-primary'
      $('#dropdownMenuButton3').removeClass 'btn-outline-primary'

  Filters.update_prices = ->
    if $('.price-range-slider #min_price').val() == "0" && $('.price-range-slider #max_price').val() == "1500" && $('.discounts:checked').length == 0
      $('#dropdownMenuButton4').removeClass 'btn-primary'
      $('#dropdownMenuButton4').addClass 'btn-outline-primary'
    else
      $('#dropdownMenuButton4').addClass 'btn-primary'
      $('#dropdownMenuButton4').removeClass 'btn-outline-primary'

).call this
