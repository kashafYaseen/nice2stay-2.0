(->
  window.Lodging or (window.Lodging = {})

  check_values = (value) ->
    value == ''

  display_bill = (values, lodging_id) ->
    url = $('.persisted-data').data('url')
    $("#lbl-error-#{lodging_id}").text('')
    $.ajax
      url: "#{url}?values=#{values}"
      type: 'GET'
      success: (data) ->
        result = ""
        total = 0
        validate(values)
        $.each data.rates, (key, value) ->
          result += "<span class='float-left'>#{value} #{if value > 1 then 'nights' else 'night'}</span> <span class='float-right'><b>€#{key}/night</b></span></br><hr>"
          total += (key * value)

        if data.discount
          discount = total * data.discount/100
          result += "<span class='float-left'>Discount #{data.discount}%</span> <span class='float-right'><b>$#{discount}</b></span>"
          total -= discount

        if total > 0
          result += "<span class='float-left'><b>Total</b></span> <span class='float-right'><b>€#{total}</b></span>"
          $("#bill-#{lodging_id}").html(result)
        else
          $("#bill-#{lodging_id}").text('Lodging not available.')

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

  Lodging.calculate_bill = (lodging_ids) ->
    for lodging_id in lodging_ids
      values = [$("#check_in_#{lodging_id}").val(), $("#check_out_#{lodging_id}").val(),
                $("#adults_#{lodging_id}").val(), $("#children_#{lodging_id}").val(),
                $("#infants_#{lodging_id}").val(), lodging_id]

      if values.some(check_values)
        $("#lbl-error-#{lodging_id}").text('Please select dates & guest details')
        $("#bill-#{lodging_id}").text('')
      else
        display_bill(values, lodging_id)

  Lodging.init_bill_calculation = ->
    $('.btn-calculate-bill').click (e) ->
      e.preventDefault()
      Lodging.calculate_bill($(this).data('lodging-ids'))
      if !$('#standalone').val()
        $('.children-scroll-section').get(0).scrollIntoView({behavior: "instant", block: "start", inline: "nearest"})
        $('#parent-form-modal').modal('hide')

  Lodging.read_more = ->
    $('.btn-read-more').click ->
      $target = $($(this).data('target'))
      if $(this).text() == "Read more"
        $target.html($(this).data('actual'))
        $(this).text('Show less')
      else
        $target.html($(this).data('truncated'))
        $(this).text('Read more')

  validate = (values) ->
    url = $('.persisted-data').data('validate-url');
    $.ajax
      url: "#{url}?values=#{values}"
      type: 'GET'
      success: (data) ->
        return

  Lodging.autocomplete = ->
    lodgings = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: '/lodgings/autocomplete?query=%QUERY'
        wildcard: '%QUERY')
    $('.autocomplete').typeahead null, displayKey: 'name', source: lodgings

    $('.autocomplete').bind 'typeahead:selected', (obj, datum) ->
      window.location.href = "/lodgings/#{datum.id}?check_in=#{$('#check_in').val()}&check_out=#{$('#check_out').val()}"

).call this
