(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    filters()
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
      $(offer).find('.tax-price').text "€#{$(offer).data('tax')}"

    $(radio).parents('form').find('.meal-price').val $(radio).find('.meal_check_box:checked').data('price')
    $(radio).parents('form').find('.meal-tax').val $(radio).find('.meal_check_box:checked').data('tax')
    $('.offer-id').val $(radio).find('.offers-select-radio').val()
    $('.offer-rent').val $(radio).data('price')
    $('.total-tax').val $(radio).data('tax')
    $('.additional-fee').val $(radio).data('fee')
    $('.room-type').val $(radio).data('type')

    if $(radio).data('child')
      $('.gc-child-id').val $(radio).data('child')

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

  filters = ->
    $('body').on 'click', '.btn-offer-filter', (e) ->
      $(this).toggleClass('selected')
      $(this).toggleClass('btn-white btn-primary')

      if $('.btn-offer-filter.selected').length > 0
        $('.children-scroll-section').addClass 'd-none'
        for button in $('.btn-offer-filter.selected')
          $("body").find("[data-offer-filter='#{$(button).data('offer')}']").removeClass 'd-none'
      else
        $('.children-scroll-section').removeClass 'd-none'

).call this
