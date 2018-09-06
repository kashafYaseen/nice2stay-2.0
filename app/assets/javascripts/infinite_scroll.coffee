(->
  window.InfiniteScroll or (window.InfiniteScroll = {})

  InfiniteScroll.init = ->
    $(window).scroll ->
      ele = $('html').get(0)
      if ele.scrollHeight - (ele.scrollTop) == (ele.clientHeight)
        url = $('.pagination .next-page').attr('href')
        if url
          $.getScript(url)
          $('#loader').show();

).call this
