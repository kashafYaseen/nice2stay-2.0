(->
  window.Voucher or (window.Voucher = {})

  Voucher.init = ->
    form = $('#new_voucher')
    form.validate
      errorPlacement: (error, element) ->
        if element.is(':checkbox')
          $(element).next().after error
        else
          element.before error
        return
      rules: 'voucher[terms_and_conditions]': required: true
      messages: 'voucher[terms_and_conditions]': required: 'Please agree to the Terms and Conditions'

    $('#wizard').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'fade'
      enableAllSteps: true
      transitionEffectSpeed: 500
      onStepChanging: (event, currentIndex, newIndex) ->
        if newIndex == 1
          $('.steps ul').addClass 'step-2'
        else
          $('.steps ul').removeClass 'step-2'
        if newIndex == 2
          $('.steps ul').addClass 'step-3'
        else
          $('.steps ul').removeClass 'step-3'
        if newIndex == 3
          $('.steps ul').addClass 'step-4'
          $('.actions ul').addClass 'step-last'
        else
          $('.steps ul').removeClass 'step-4'
          $('.actions ul').removeClass 'step-last'
        true
      labels:
        finish: 'Submit'
        next: 'Next'
        previous: 'Previous'
      onStepChanging: (event, currentIndex, newIndex) ->
        form.validate().settings.ignore = ':disabled,:hidden'
        form.valid()
      onFinishing: (event, currentIndex) ->
        form.validate().settings.ignore = ':disabled'
        form.valid()
      onFinished: ->
        $('#new_voucher').submit()
        return

    $('.wizard > .steps li a').click ->
      $(this).parent().addClass 'checked'
      $(this).parent().prevAll().addClass 'checked'
      $(this).parent().nextAll().removeClass 'checked'
      return

    # Custom Button Jquery Steps
    $('.forward').click ->
      $('#wizard').steps 'next'
      return

    $('.backward').click ->
      $('#wizard').steps 'previous'
      return

    # Checkbox
    $('.checkbox-circle label').click ->
      $('.checkbox-circle label').removeClass 'active'
      $(this).addClass 'active'
      return

    resize_background()

  resize_background = ->
    box = document.querySelector('#wizard')
    backgroundImage = document.querySelector('.vouchers-jumbotron-bg')
    backgroundImageOverlay = document.querySelector('.dark-overlay-image')
    observer = new ResizeObserver((enteries) ->
      formContainer = enteries[0]
      isLarge = formContainer.contentRect.height > 500
      backgroundImage.style.height = if isLarge then '130vh' else '100vh'
      backgroundImageOverlay.style.height = if isLarge then '130vh' else '100vh'
      return
    )
    observer.observe box

).call this
