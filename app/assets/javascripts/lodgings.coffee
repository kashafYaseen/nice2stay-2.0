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
    if values.some(check_values)
      $('#lbl-error').text('Please select dates & guest details')
      $('#bill').text('')
    else
      $('#lbl-error').text('')
      $.ajax
        url: "#{$('#lodging-url').data('url')}?values=#{values}"
        type: 'GET'
        success: (rates) ->
          result = ""
          total = 0
          $.each rates, (key, value) ->
            result += "<p>$#{key} x #{value} night</p>"
            total += (key * value)

          if total > 0
            result += "<p>total: #{total}</p>"
            $('#bill').html(result)
          else
            $('#bill').text('Lodging not available.')

).call this
