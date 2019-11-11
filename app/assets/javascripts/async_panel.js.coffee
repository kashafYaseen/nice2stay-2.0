$ ->
  $('.async-panel').each (index, item) ->
    item = $(item)
    item.addClass('processing')
    $('h3', item).hide().show(0)

    $.ajax
      url: item.data('url')
      success: (data) ->
        $('.panel_contents', item).html(data)
      error: (data, status, error) ->
        $('.panel_contents', item).html(error)
      complete: ->
        item.removeClass('processing')

  $('.toggle-sidebar').click ->
    if $('.header-item.tabs').hasClass 'd-none'
      $('.header-item.tabs').removeClass 'd-none'
      $('body').removeClass 'pl-0'
    else
      $('.header-item.tabs').addClass 'd-none'
      $('body').addClass 'pl-0'
