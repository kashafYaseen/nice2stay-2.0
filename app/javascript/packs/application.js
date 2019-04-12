/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import Vue from 'vue/dist/vue.esm.js'
import Datepicker from '../vue_components/datepicker.vue'
import ReservationDatepicker from '../vue_components/reservation_datepicker.vue'
import TurbolinksAdapter from 'vue-turbolinks'
import AirbnbStyleDatepicker from 'vue-airbnb-style-datepicker'
import 'vue-airbnb-style-datepicker/dist/vue-airbnb-style-datepicker.min.css'

Vue.use(TurbolinksAdapter)
Vue.use(AirbnbStyleDatepicker, { colors: { disabled: '#e2dede' } })

window.initDatePicker = function() {
  if ($('#vue-app').length) {
    window.app = new Vue({
      el: '#vue-app',
      components: {
        ReservationDatepicker,
        Datepicker
      }
    })
  }

  if ($('#searchbar-vue-app').length) {
    window.app = new Vue({
      el: '#searchbar-vue-app',
      components: {
        Datepicker
      }
    })
  }
}
