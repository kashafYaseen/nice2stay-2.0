(->
  window.OwlCarousel or (window.OwlCarousel = {})

  OwlCarousel.init = ->
    $(".owl-carousel").owlCarousel
      items: 1
      loop: true
      dots: false
      nav: true
      navText: false
      autoHeight: true

).call this
