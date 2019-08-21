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
