(->
  window.Lodging or (window.Lodging = {})

  check_values = (value) ->
    value == ''

  Lodging.init = ->
    Slider.init()
    $('.lodging_type').change ->
      $(this).parents('form').submit()

    $('.lowest-price, .highest-price').click ->
      if $(this).hasClass 'lowest-price'
        $('#order').val('price_asc')
      else if $(this).hasClass 'highest-price'
        $('#order').val('price_desc')
      $(this).parents('form').submit()

  Lodging.update_bill = (values) ->
    child_id = values[5]
    if values.some(check_values)
      $("#lbl-error-#{child_id}").text('Please select dates & guest details')
      $("#bill-#{child_id}").text('')
    else
      url = $('.persisted-data').data('url')
      $("#lbl-error-#{child_id}").text('')
      $.ajax
        url: "#{url}?values=#{values}"
        type: 'GET'
        success: (data) ->
          result = ""
          total = 0
          validate(values)
          $.each data.rates, (key, value) ->
            result += "<b>€ #{key} x #{value} night</b>"
            total += (key * value)


          if data.discount
            discount = total * data.discount/100
            result += "<p>Discount #{data.discount}% : $#{discount}</p>"
            total -= discount

          if total > 0
            result += "<p>total: #{total}</p>"
            $("#bill-#{child_id}").html(result)
          else
            $("#bill-#{child_id}").text('Lodging not available.')

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
