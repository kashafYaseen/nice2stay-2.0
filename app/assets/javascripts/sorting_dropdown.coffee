(->
  window.SortingDropdown or (window.SortingDropdown = {})

  SortingDropdown.init = ->
    $('.sorting-dropdown-menu .dropdown-item').click ->
      if $(this).hasClass 'lowest-price'
        $('#order').val('price_asc')
        $('.price-dropdown .dropdown-toggle .title').text('Lowest to Highest')
      else if $(this).hasClass 'highest-price'
        $('#order').val('price_desc')
        $('.price-dropdown .dropdown-toggle .title').text('Highest to Lowest')
      else if $(this).hasClass 'highest-rating'
        $('#order').val('rating_desc')
        $('.price-dropdown .dropdown-toggle .title').text('Highest Rating')
      else if $(this).hasClass 'newest'
        $('#order').val('new_desc')
        $('.price-dropdown .dropdown-toggle .title').text('Newest')
      else if $(this).hasClass 'default'
        $('#order').val('')
        $('.price-dropdown .dropdown-toggle .title').text('Sort By')
      Filters.submit()

).call this
