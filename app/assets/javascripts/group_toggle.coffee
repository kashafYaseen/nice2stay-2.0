(->
  window.GroupToggle or (window.GroupToggle = {})

  GroupToggle.init = ->
    $('body').on 'click', '.group-toggle .group-toggle-radio', ->
      $(this).siblings('.group-toggle-radio').removeClass 'border-primary'
      $(this).siblings('.group-toggle-radio').addClass 'border-dark'
      $(this).removeClass 'border-dark'
      $(this).addClass 'border-primary'

).call this
