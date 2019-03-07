(->
  window.Invoice or (window.Invoice = {})

  Invoice.init = ->
    $('.btn-calculate-bill').click (e) ->
      e.preventDefault()
      Invoice.calculate($(this).data('lodging-ids'))
      if $('.children-scroll-section').length > 0
        $('.children-scroll-section').get(0).scrollIntoView({behavior: "instant", block: "start", inline: "nearest"})
        $('#parent-form-modal').modal('hide')

    $('.flexible-search-data').on 'change', '.flexible_search_radio', ->
      if $(this).is(':checked')
        lodging_id = $(this).data('id')
        $("#check_in_#{lodging_id}").val($(this).data('check-in'))
        $("#check_out_#{lodging_id}").val($(this).data('check-out'))
        values = [$("#check_in_#{lodging_id}").val(), $("#check_out_#{lodging_id}").val(),
                  $("#adults_#{lodging_id}").val(), $("#children_#{lodging_id}").val(),
                  $("#infants_#{lodging_id}").val(), lodging_id]
        if values[4] == '' then values[4] = 0
        if values[3] == '' then values[3] = 0

        $('.search-results').addClass 'd-none'
        $(".#{$(this).val()}").removeClass 'd-none'
        Reservation.validate(values)

  Invoice.calculate = (lodging_ids) ->
    Rails.fire($('.you-may-like-form').get(0), 'submit')
    for lodging_id in lodging_ids
      values = [$("#check_in_#{lodging_id}").val(), $("#check_out_#{lodging_id}").val(),
                $("#adults_#{lodging_id}").val(), $("#children_#{lodging_id}").val(),
                $("#infants_#{lodging_id}").val(), lodging_id]
      if values[4] == '' then values[4] = 0
      if values[3] == '' then values[3] = 0

      if values.some(check_values)
        $("#lbl-error-#{lodging_id}").text('Please select dates & guest details')
        $("#bill-#{lodging_id}").text('')
      else
        Invoice.print(values, lodging_id)

  Invoice.print = (values, lodging_id) ->
    url = $('.persisted-data').data('url')
    $("#lbl-error-#{lodging_id}").html('')
    $("#bill-#{lodging_id}").html('')
    $(".anternative-heading").html('')
    $(".child-form-errors").html('')

    $.ajax
      url: "#{url}?values=#{values}"
      type: 'GET'
      success: (data) ->
        $("#flexible-search-#{lodging_id}").html('');
        if data.flexible
          print_flexible(values, lodging_id, data)
        else
          print_default(values, lodging_id, data)

  print_flexible = (values, lodging_id, data) ->
    index = 0
    for search_param in data.search_params
      result = ""
      total = 0
      nights = 0
      values[0] = search_param['check_in']
      values[1] = search_param['check_out']

      if index == 0
        $("#check_in_#{lodging_id}").val(values[0])
        $("#check_out_#{lodging_id}").val(values[1])

      $.each data.rates[index], (key, value) ->
        result += rates_html(key, value, index)
        total += (key * value)
        nights += value

      if data.valid[index]
        $("#cart-#{lodging_id}").removeClass('disabled');
        $(".reservation-form-errors-#{lodging_id}").html('');
        $("#flexible-search-#{lodging_id}").append(radio_buttom_html(values[0], values[1], total, nights, lodging_id, index))

        if data.discounts[index]
          total_discount = 0
          $.each data.discounts[index], (i, discount) ->
            if discount.discount_type == "percentage"
              total_discount += (total * discount.value/100)
            else
              total_discount += discount.value
          if total_discount > 0
            result += discount_html("Discount", total_discount, index)
          total -= total_discount
          $("#discount_#{lodging_id}").val(total_discount)

        if data.cleaning_costs
          total_cleaning_cost = 0
          $.each data.cleaning_costs, (i, cost) ->
            if cost.fixed_price > 0
              total_cleaning_cost += cost.fixed_price
              total += cost.fixed_price
              result += cleaning_cost_html(cost, index, nights)
            else if cost.price_per_day > 0
              total_cleaning_cost += (cost.price_per_day * nights)
              total += (cost.price_per_day * nights)
              result += cleaning_cost_html(cost, -1, nights)

          $("#cleaning_cost_#{lodging_id}").val(total_cleaning_cost)

        if total > 0
          result += total_html(total, index)
          $("#anternative-heading-#{lodging_id}").html('Selected period is not available. See alternatives')
          $("#bill-#{lodging_id}").append(result)
        else
          show_unavailable(lodging_id)
      else
        show_unavailable(lodging_id)
      index += 1

  print_default = (values, lodging_id, data) ->
    result = ""
    total = 0
    nights = 0
    $.each data.rates, (key, value) ->
      result += rates_html(key, value, -1)
      total += (key * value)
      nights += value

    if nights >= 1 && data.valid
      $("#cart-#{lodging_id}").removeClass('disabled');
      $(".reservation-form-errors-#{lodging_id}").html('');

      if data.discounts
        total_discount = 0
        $.each data.discounts, (i, discount) ->
          if discount.discount_type == "percentage"
            total_discount += (total * discount.value/100)
          else
            total_discount += discount.value

      if data.cleaning_costs
        total_cleaning_cost = 0
        $.each data.cleaning_costs, (index, cost) ->

          if cost.fixed_price > 0
            total_cleaning_cost += cost.fixed_price
            total += cost.fixed_price
            result += cleaning_cost_html(cost, -1, nights)
          else if cost.price_per_day > 0
            total_cleaning_cost += (cost.price_per_day * nights)
            total += (cost.price_per_day * nights)
            result += cleaning_cost_html(cost, -1, nights)
        $("#cleaning_cost_#{lodging_id}").val(total_cleaning_cost)

        if total_discount > 0
          result += discount_html("Discount", total_discount, -1)
        total -= total_discount
        $("#discount_#{lodging_id}").val(total_discount)

      if total > 0
        result += total_html(total, -1)
        $('.sm-total').text("Price: $#{total}")
        $("#bill-#{lodging_id}").html(result)
        $("#anternative-heading-#{lodging_id}").html('Good news period is fully available.')
        $("#flexible-search-#{lodging_id}").html("#{parse_date values[0]} - #{parse_date values[1]}")
      else
        show_unavailable(lodging_id)
    else
      Reservation.validate(values)

  show_unavailable = (lodging_id) ->
    $("#bill-#{lodging_id}").text('Lodging is not available.')

  check_values = (value) ->
    value == '' || value == undefined

  rates_html = (key, value, index) ->
    return "<p class='flexible-search-#{index} #{if index < 0 then '' else 'search-results'} #{if index > 0 then 'd-none' else ''} row mb-0'>
              <span class='col-6'>#{value} #{if value > 1 then 'nights' else 'night'}</span>
              <span class='col-6'><b>€#{parseFloat(key).toFixed(2)}/night</b></span>
            </p>"

  discount_html = (key, value, index) ->
   return "<p class='flexible-search-#{index} #{if index < 0 then '' else 'search-results'} #{if index > 0 then 'd-none' else ''} row mb-0'>
            <span class='col-6'>Discount</span>
            <span class='col-6'><b>€#{value.toFixed(2)}</b></span>
          </p>"

  cleaning_cost_html = (cost, index, nights) ->
    return "<p class='flexible-search-#{index} #{if index < 0 then '' else 'search-results'} #{if index > 0 then 'd-none' else ''} row mb-0'>
              <span class='col-6'><b>#{cost.name}</b></span>
              <span class='col-6'><b>€#{if cost.fixed_price > 0 then cost.fixed_price.toFixed(2) else (cost.price_per_day * nights).toFixed(2)}</b></span>
            </p>"

  total_html = (total, index) ->
    return "<p class='flexible-search-#{index} #{if index < 0 then '' else 'search-results'} #{if index > 0 then 'd-none' else ''} row mb-0'>
              <span class='col-6'><b>Total</b></span>
              <span class='col-6'><b>€#{total.toFixed(2)}</b></span>
            </p>"

  radio_buttom_html = (check_in, check_out, price, nights, lodging_id, index) ->
    return "<input type='radio' name='flexible_search' class='flexible_search_radio' value='flexible-search-#{index}' data-id='#{lodging_id}' data-check-in='#{check_in}' data-check-out='#{check_out}' #{if index == 0 then 'checked'}>
           #{parse_date check_in} - #{parse_date check_out} - #{nights} nights - <b>€#{price}</b><br>"

  parse_date = (date) ->
    return "#{date.split('-')[2]}-#{date.split('-')[1]}-#{date.split('-')[0]}"

).call this
