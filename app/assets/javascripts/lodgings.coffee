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
            $('#bill').html(result)
          else
            $('#bill').text('Lodging not available.')

  validate = (values) ->
    values.push $('#reservation_lodging_id').val()
    $.ajax
      url: "/reservations/validate?values=#{values}"
      type: 'GET'
      success: (data) ->
        return

).call this
