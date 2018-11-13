(->
  window.InfiniteScroll or (window.InfiniteScroll = {})

  InfiniteScroll.init = (base_url) ->
    $(window).scroll ->
      ele = $('html').get(0)
      if ele.scrollHeight - (ele.scrollTop) == (ele.clientHeight)
        url = $('.pagination .next-page').attr('href')
        if url
          $.getScript("#{base_url}?#{url.split('?')[1]}")
          $('#loader').show();

).call this
