(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.guest-centric-modal-btn, .offers-select-radio', ->
      radio = $(this).parents('label')
      $(radio).siblings('label').find('.meal_check_box').prop('checked', false);

      $('#target_modal').val $(this).data('target')
      select_item(radio)
      submit_form(radio)

    $('#guest_centric_offers').on 'change', '.meal_check_box', ->
      radio = $(this).parents('label')
      $(radio).siblings('label').find('.meal_check_box').prop('checked', false);

      if $(this).is(':checked')
        $(radio).find('.meal_check_box').prop('checked', false);
        $(this).prop('checked', true);

      $('#target_modal').val ''
      select_item(radio)
      submit_form(radio)

  select_item = (radio) ->
    $(radio).siblings('label').removeClass 'border-primary'
    $(radio).siblings('label').addClass 'border-dark'

    $(radio).parents('form').find('.meal-price').val $(radio).find('.meal_check_box:checked').data('price')

    $('.offer-id').val $(radio).find('.offers-select-radio').val()
    $(radio).removeClass 'border-dark'
    $(radio).addClass 'border-primary'

  submit_form = (radio) ->
    if $(radio).data('submit') && $(radio).data('bookable')
      $('#loader').show()
      Rails.fire($($(radio).data('submit')).get(0), 'submit')
      $(radio).parents('form').find('.restrictions').removeClass 'text-danger'
    else
      $(radio).parents('form').find('.restrictions').addClass 'text-danger'

).call this
