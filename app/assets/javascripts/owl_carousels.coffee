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

    $(".owl-carousel-full").not('.slick-initialized').slick
      dots: false,
      infinite: true,
      speed: 300,
      slidesToShow: 1,
      centerMode: false,
      variableWidth: true

    $('.slick-prev.slick-arrow, .slick-next.slick-arrow').text('')

).call this
