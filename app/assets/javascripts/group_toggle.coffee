(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.group-toggle .group-toggle-radio', ->
      $(this).siblings('.group-toggle-radio').removeClass 'border-primary'
      $(this).siblings('.group-toggle-radio').addClass 'border-dark'
      $('.offer-id').val $(this).find('.offers-select-radio').val()
      $(this).removeClass 'border-dark'
      $(this).addClass 'border-primary'
      if $(this).data('submit')
        Rails.fire($($(this).data('submit')).get(0), 'submit')

).call this
