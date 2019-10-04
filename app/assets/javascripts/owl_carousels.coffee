(->
  window.OwlCarousel or (window.OwlCarousel = {})

  OwlCarousel.init = ->
    $(".owl-carousel").not($(".owl-carousel-full")).owlCarousel
      items: 1
      loop: true
      dots: false
      nav: true
      navText: false
      autoHeight: false

    $(".owl-carousel-full").owlCarousel
      items: 2
      loop: true
      dots: false
      nav: true
      navText: false
      autoHeight: true
      autoWidth: true
      margin:10

).call this
