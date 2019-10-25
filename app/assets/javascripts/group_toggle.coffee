(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.guest-centric-modal-btn, .offers-select-radio', ->
      radio = $(this).parents('label')
      $('.meal_check_box').not(radio.find('.meal_check_box')).prop('checked', false);

      $('#target_modal').val $(this).data('target')
      select_item(radio)
      submit_form(radio)

    $('#guest_centric_offers').on 'change', '.meal_check_box', ->
      radio = $(this).parents('label')
      $('.meal_check_box').not(this).prop('checked', false);

      if $(this).is(':checked')
        $(radio).find('.meal_check_box').prop('checked', false);
        $(this).prop('checked', true);

      $('#target_modal').val ''
      select_item(radio)
      submit_form(radio)

  select_item = (radio) ->
    deselect_all()
    for offer in $('.offer-item').not(radio)
      $(offer).find('.offer-price').text "€#{$(offer).data('price')}"

    $(radio).parents('form').find('.meal-price').val $(radio).find('.meal_check_box:checked').data('price')
    $(radio).parents('form').find('.meal-tax').val $(radio).find('.meal_check_box:checked').data('tax')
    $('.offer-id').val $(radio).find('.offers-select-radio').val()
    $('.offer-rent').val $(radio).data('price')
    $('.total-tax').val $(radio).data('tax')
    $(radio).removeClass 'border-dark'
    $(radio).addClass 'border-primary'

  deselect_all = ->
    $('label.offer-item').removeClass 'border-primary border-danger'
    $('label.offer-item').addClass 'border-dark'
    $('.btn-booking').not('.guest-centric-modal .btn-booking').addClass 'disabled'
    $('.offer-price').text ''

  submit_form = (radio) ->
    if $(radio).data('submit') && $(radio).data('bookable')
      $('#loader').show()
      Rails.fire($($(radio).data('submit')).get(0), 'submit')
      $(radio).parents('form').find('.restrictions').removeClass 'text-danger'
    else
      $(radio).parents('form').find('.restrictions').addClass 'text-danger'
      $(radio).addClass 'border-danger'
      $(radio).find('.offers-select-radio').prop('checked', false)

).call this
