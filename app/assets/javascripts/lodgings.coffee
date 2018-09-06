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

  Lodging.autocomplete = (url) ->
    lodgings = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{url}?query=%QUERY"
        wildcard: '%QUERY')
    $('.autocomplete').typeahead null, displayKey: 'name', source: lodgings

    $('.autocomplete').bind 'typeahead:selected', (obj, datum) ->
      window.location.href = "#{datum.url}?check_in=#{$('.check-in').val()}&check_out=#{$('.check-out').val()}"

).call this
