(->
  window.SidebarCanvas or (window.SidebarCanvas = {})

  SidebarCanvas.init = (trigger_open, target, trigger_close) ->
    $(trigger_open).on 'click', ->
      $(this).addClass 'sidebar-open'
      $(target).addClass 'open'
    $(trigger_close).on 'click', ->
      $(trigger_open).removeClass 'sidebar-open'
      $(target).removeClass 'open'

).call this
