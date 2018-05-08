
InitDatepicker = function() {
  var datepickerOptions = {
    sundayFirst: true
  }

  Vue.use(window.AirbnbStyleDatepicker, datepickerOptions)

  var app = new Vue({
    el: '#datepicker',
    data: {
      check_in: '',
      check_out: ''
    }
  })
}
