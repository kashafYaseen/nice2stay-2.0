(->
  window.Lodging or (window.Lodging = {})

  Lodging.init = ->
    Slider.init()
    $('.lodging_type').change ->
      $('#loader').show();
      Rails.fire($('.lodgings-filters').get(0), 'submit')

    $('.lowest-price, .highest-price').click ->
      $('.price-dropdown .dropdown-toggle').addClass 'btn-primary'
      $('.price-dropdown .dropdown-toggle').removeClass 'btn-outline-primary'

      if $(this).hasClass 'lowest-price'
        $('#order').val('price_asc')
        $('.price-dropdown .dropdown-toggle .title').text('Lowest to Highest')
      else if $(this).hasClass 'highest-price'
        $('#order').val('price_desc')
        $('.price-dropdown .dropdown-toggle .title').text('Highest to Lowest')
      $('#loader').show();
      Rails.fire($('.lodgings-filters').get(0), 'submit')

    $('.submit-filters').click ->
      $('#loader').show();
      $('#more-filters-modal').modal('hide')

    $('.show-all-filters').click (e) ->
      e.stopPropagation()
      if $(this).text().includes("show all")
        $($(this).data('target')).removeClass 'filters-show-less'
        $(this).text("close #{$(this).data('name')}")
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
    $(window).scroll ->
      $('.target-section').each ->
        if $(window).scrollTop() >= $(this).position().top - $('.navbar').height()
          id = $(this).attr('id')
          $('#details-navbar .nav-link').removeClass 'active'
          $("a[href='##{id}']").addClass 'active'

  Lodging.read_more = ->
    $('.btn-read-more').click ->
      $target = $($(this).data('target'))
      if $(this).text() == "Read more"
        $target.html($(this).data('actual'))
        $(this).text('Show less')
      else
        $target.html($(this).data('truncated'))
        $(this).text('Read more')

).call this
