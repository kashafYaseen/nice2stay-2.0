(->
  window.Filters or (window.Filters = {})

  Filters.init = ->
    updated_amenities_and_experiences()
    update_lodging_types()

    $('.more-filters-btn').click ->
      $('#more-filters').modal('toggle')
      $('.modal-backdrop').css('z-index', 1);

    $('.amenities, .experiences').change ->
      updated_amenities_and_experiences()

    $('.submit-filters').click ->
      $('#loader').show();
      Rails.fire($('.search-filters .lodgings-filters').get(0), 'submit')
      $('#more-filters').modal('hide');

    $('.search-filters .lodging_type').change ->
      update_lodging_types()
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

).call this
