(->
  window.Lodging or (window.Lodging = {})

  check_values = (value) ->
    value == ''

  Lodging.init = ->
    Slider.init()
    $('.lodging_type').change ->
      Rails.fire($('.lodgings-filters').get(0), 'submit')

    $('.lowest-price, .highest-price').click ->
      if $(this).hasClass 'lowest-price'
        $('#order').val('price_asc')
      else if $(this).hasClass 'highest-price'
        $('#order').val('price_desc')
      Rails.fire($('.lodgings-filters').get(0), 'submit')

  Lodging.update_bill = (values) ->
    if values.some(check_values)
      $("#lbl-error").text('Please select dates & guest details')
      $("#bill").text('')
    else
      url = $('.persisted-data').data('url')
      $("#lbl-error").text('')
      $.ajax
        url: "#{url}?values=#{values}"
        type: 'GET'
        success: (data) ->
          result = ""
          total = 0
          validate(values)
          $.each data.rates, (key, value) ->
            result += "<b>€ #{key} x #{value} night</b></br>"
            total += (key * value)


          if data.discount
            discount = total * data.discount/100
            result += "<p>Discount #{data.discount}% : $#{discount}</p>"
            total -= discount

          if total > 0
            result += "<p>total: #{total}</p>"
            $("#bill").html(result)
          else
            $("#bill").text('Lodging not available.')

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
    $('.autocomplete').typeahead null, source: lodgings

).call this
