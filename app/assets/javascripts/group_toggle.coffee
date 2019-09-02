(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.guest-centric-modal-btn', ->
      radio = $(this).nextAll('.group-toggle-radio').first()
      $(radio).siblings('.group-toggle-radio').removeClass 'border-primary'
      $(radio).siblings('.group-toggle-radio').addClass 'border-dark'
      $('.offer-id').val $(radio).find('.offers-select-radio').val()
      $('#target_modal').val $(this).data('target')
      $(radio).removeClass 'border-dark'
      $(radio).addClass 'border-primary'
      if $(radio).data('submit')
        $('#loader').show()
        Rails.fire($($(radio).data('submit')).get(0), 'submit')

    $('body').on 'click', '.group-toggle .group-toggle-radio', ->
      $(this).siblings('.group-toggle-radio').removeClass 'border-primary'
      $(this).siblings('.group-toggle-radio').addClass 'border-dark'
      $('.offer-id').val $(this).find('.offers-select-radio').val()
      $(this).removeClass 'border-dark'
      $(this).addClass 'border-primary'
      $('#target_modal').val ''
      if $(this).data('submit')
        $('#loader').show()
        Rails.fire($($(this).data('submit')).get(0), 'submit')

).call this
