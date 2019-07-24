$ ->
  $('.async-panel').each (index, item) ->
    item = $(item)
    worker = ->
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

          # Schedule the next request when the current one's completed
          period = item.data('period')
          if period
            setTimeout worker, period * 1000

    worker()
