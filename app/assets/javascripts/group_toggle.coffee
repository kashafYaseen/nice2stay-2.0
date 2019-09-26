(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.guest-centric-modal-btn, .offers-select-radio', ->
      radio = $(this).parent()
      $('#target_modal').val $(this).data('target')
      select_item(radio)
      submit_form(radio)

    $('#guest_centric_offers').on 'change', '.meal_check_box', ->
      radio = $(this).parents('label')
      $('#target_modal').val ''
      select_item(radio)
      submit_form(radio)

  select_item = (radio) ->
    $(radio).siblings('label').removeClass 'border-primary'
    $(radio).siblings('label').addClass 'border-dark'

    meal_price = 0
    for meal in $(radio).find('.meal_check_box:checked')
      meal_price += $(meal).data('price')
    $(radio).parents('form').find('.meal-price').val meal_price

    $('.offer-id').val $(radio).find('.offers-select-radio').val()
    $(radio).removeClass 'border-dark'
    $(radio).addClass 'border-primary'

  submit_form = (radio) ->
    if $(radio).data('submit') && $(radio).data('bookable')
      $('#loader').show()
      Rails.fire($($(radio).data('submit')).get(0), 'submit')

).call this
