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

  Lodging.update_bill = ->
    $('.calculate').click (e) ->
      e.preventDefault();
      values = [$("input[name='reservation[check_in]']").val(),
                $("input[name='reservation[check_out]']").val(),
                $('#reservation_adults').val(),
                $('#reservation_children').val(),
                $('#reservation_infants').val()]

      if values.some(check_values)
        $('#lbl-error').text('Please select dates & guest details')
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
