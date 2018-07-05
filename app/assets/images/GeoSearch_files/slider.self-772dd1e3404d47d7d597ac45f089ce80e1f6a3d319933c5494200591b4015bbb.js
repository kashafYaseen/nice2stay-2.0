(function() {
  (function() {
    window.Slider || (window.Slider = {});
    return Slider.init = function() {
      var bar, el, elem, lb, max, microsecMax, props, sp, startOffset, stp;
      elem = document.querySelector('.ui-range-slider');
      if (void 0 !== elem && null !== elem) {
        startOffset = parseInt(elem.parentNode.getAttribute('data-start-min'), 10);
        max = parseInt(elem.parentNode.getAttribute('data-start-max'), 10);
        lb = parseInt(elem.parentNode.getAttribute('data-min'), 10);
        microsecMax = parseInt(elem.parentNode.getAttribute('data-max'), 10);
        stp = parseInt(elem.parentNode.getAttribute('data-step'), 10);
        sp = document.querySelector('.ui-range-value-min span');
        props = document.querySelector('.ui-range-value-max span');
        bar = document.querySelector('.ui-range-value-min input');
        el = document.querySelector('.ui-range-value-max input');
        noUiSlider.create(elem, {
          start: [startOffset, max],
          connect: true,
          step: stp,
          range: {
            min: lb,
            max: microsecMax
          }
        });
        return elem.noUiSlider.on('update', function(_meta, index) {
          var value;
          value = _meta[index];
          if (index) {
            props.innerHTML = Math.round(value);
            return el.value = Math.round(value);
          } else {
            sp.innerHTML = Math.round(value);
            return bar.value = Math.round(value);
          }
        });
      }
    };
  }).call(this);

}).call(this);
