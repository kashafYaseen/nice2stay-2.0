(->
  window.HomePageSlider or (window.HomePageSlider = {})

  HomePageSlider.init = ->
    swiper = new Swiper('.swiper-container',
      speed: 600
      loop: true
      pagination:
        el: '.swiper-pagination'
        clickable: true
      navigation:
        nextEl: '.swiper-button-next'
        prevEl: '.swiper-button-prev')

).call this
