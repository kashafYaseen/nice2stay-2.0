(->
  window.Url or (window.Url = {})

  Url.update = ->
    params = ""
    if $('#bounds').val()    then params += "&bounds=#{$('#bounds').val()}"
    if $('.check-in').val()  then params += "&check_in=#{$('.check-in').val()}"
    if $('.check-out').val() then params += "&check_out=#{$('.check-out').val()}"
    if $('#adults').val()    then params += "&adults=#{$('#adults').val()}"
    if $('#children').val()  then params += "&children=#{$('#children').val()}"
    if $('#infants').val()   then params += "&infants=#{$('#infants').val()}"
    if $('#min_price').val() then params += "&min_price=#{$('#min_price').val()}"
    if $('#max_price').val() then params += "&max_price=#{$('#max_price').val()}"
    if $('#order').val()     then params += "&order=#{$('#order').val()}"
    if $('#region').val()    then params += "&region=#{$('#region').val()}"
    if $('#lodging_type_villa').is(':checked')        then params += "&lodging_type_in[]=#{$('#lodging_type_villa').val()}"
    if $('#lodging_type_apartment').is(':checked')    then params += "&lodging_type_in[]=#{$('#lodging_type_apartment').val()}"
    if $('#lodging_type_bnb').is(':checked')          then params += "&lodging_type_in[]=#{$('#lodging_type_bnb').val()}"

    window.history.pushState({}, null, "/lodgings?#{params}");

).call this