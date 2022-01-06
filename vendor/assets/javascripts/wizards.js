$(function() {
  $("#wizard").steps({
    headerTag: "h4",
    bodyTag: "section",
    transitionEffect: "fade",
    enableAllSteps: true,
    transitionEffectSpeed: 500,
    onStepChanging: function (event, currentIndex, newIndex) { 
      if ( newIndex === 1 ) {
        $('.steps ul').addClass('step-2');
      } else {
        $('.steps ul').removeClass('step-2');
      }
      if ( newIndex === 2 ) {
        $('.steps ul').addClass('step-3');
      } else {
        $('.steps ul').removeClass('step-3');
      }
      if ( newIndex === 3 ) {
        $('.steps ul').addClass('step-4');
        $('.actions ul').addClass('step-last');
      } else {
        $('.steps ul').removeClass('step-4');
        $('.actions ul').removeClass('step-last');
      }
      return true; 
    },
    labels: {
      finish: "Submit",
      next: "Next",
      previous: "Previous"
    },
    onFinished: function () {
      $('#new_voucher').submit();
    },
  });
  // Custom Steps Jquery Steps
  $('.wizard > .steps li a').click(function() {
    $(this).parent().addClass('checked');
    $(this).parent().prevAll().addClass('checked');
    $(this).parent().nextAll().removeClass('checked');
  });
  // Custom Button Jquery Steps
  $('.forward').click(function(){
    $("#wizard").steps('next');
  })
  $('.backward').click(function(){
    $("#wizard").steps('previous');
  })
  // Checkbox
  $('.checkbox-circle label').click(function(){
    $('.checkbox-circle label').removeClass('active');
    $(this).addClass('active');
  })

  const box = document.querySelector('#wizard');
  const backgroundImage = document.querySelector('.vouchers-jumbotron-bg');
  const backgroundImageOverlay = document.querySelector('.dark-overlay-image');

  const observer = new ResizeObserver((enteries) => {
    const formContainer = enteries[0]
    const isLarge = formContainer.contentRect.height > 500
    backgroundImage.style.height = isLarge ? '130vh' : '100vh'
    backgroundImageOverlay.style.height = isLarge ? '130vh' : '100vh'
  });

  observer.observe(box)
});
