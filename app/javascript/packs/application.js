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

  // if ($('#datepicker').length) {
  //   new Vue({
  //     el: '#datepicker',
  //     render(h) {
  //       return h(Datepicker, { props: {monthsToShow: 2, triggerId: 'trigger-range'} })
  //     }
  //   })
  // }

  // if ($('#searchbar-datepicker').length) {
  //   new Vue({
  //     el: '#searchbar-datepicker',
  //     render(h) {
  //       return h(Datepicker, { props: {monthsToShow: 1, triggerId: 'trigger-range-searchbar', columnClass: 'col-md-12 pl-2'} })
  //     }
  //   })
  // }

  // if ($('#home-datepicker').length) {
  //   new Vue({
  //     el: '#home-datepicker',
  //     render: h => h(HomeDatepicker)
  //   })
  // }

  // if ($('#calendar').length) {
  //   new Vue({
  //     el: '#calendar',
  //     render: h => h(Calendar)
  //   })
  // }

  if ($('.reservation-datepicker').length) {
    const vues = document.querySelectorAll(".reservation-datepicker");
    Array.prototype.forEach.call(vues, (el, index) =>
      new Vue({
        el: el,
        render: h => h(ReservationDatepicker)
      })
    )
  }
}
