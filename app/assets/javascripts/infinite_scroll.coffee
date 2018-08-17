(->
  window.InfiniteScroll or (window.InfiniteScroll = {})

  InfiniteScroll.init = ->
    $('.lodgings-list').scroll ->
      ele = document.getElementById('lodgings-list')
      if ele.scrollHeight - (ele.scrollTop) == (ele.clientHeight)
        url = $('.pagination .next-page').attr('href')
        if url
          $.getScript(url)
          $('#loader').show();

).call this
