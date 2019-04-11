(->
  window.OwlCarousel or (window.OwlCarousel = {})

  OwlCarousel.init = (options) ->
    if options
      $(".owl-carousel").owlCarousel(options)
    else
      $(".owl-carousel").owlCarousel
        items: 1
        loop: true
        dots: false
        nav: true
        navText: false

).call this
