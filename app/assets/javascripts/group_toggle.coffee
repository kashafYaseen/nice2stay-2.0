(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.guest-centric-modal-btn, .offers-select-radio', ->
      radio = $(this).parent()
      $(radio).siblings('label').removeClass 'border-primary'
      $(radio).siblings('label').addClass 'border-dark'
      $('.offer-id').val $(radio).find('.offers-select-radio').val()
      $('#target_modal').val $(this).data('target')
      $(radio).removeClass 'border-dark'
      $(radio).addClass 'border-primary'
      if $(radio).data('submit')
        $('#loader').show()
        Rails.fire($($(radio).data('submit')).get(0), 'submit')

).call this
