<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary w-100 d-none" id="datepicker-trigger">{{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="'datepicker-trigger'"
        :date-one="check_in"
        :date-two="check_out"
        @date-one-selected="date_one_selected"
        @date-two-selected="date_two_selected"
        @apply="apply"
        :inline="true"
        :months-to-show="2"
        :disabled-dates="this.disabledDates"
        :customized-dates= "this.customizedDates"
        :min-date="this.current_date.toString()"
        :show-action-buttons="true"
      ></airbnb-style-datepicker>
    </div>
  </div>
</template>

<script>
  import format from 'date-fns/format'
  export default {
    name: "reservation-datepicker",
    props: [
    "checkIn",
    "checkOut",
    "months" ,
    "checkInTitle",
    "checkOutTitle",
    "lodgingId",
    "disabledDates",
    "customizedDates"
    ],
    data() {
      let check_in = this.checkIn
      let check_out = this.checkOut
      let today = this.get_yesterday();
      return {
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        dateFormat: 'D MMM',
        current_date: today,
      }
    },
    mounted() {

    },
    methods: {
      formatDates(dateOne, dateTwo) {
        let formattedDates = ''

        if (!dateTwo && !dateOne){
          formattedDates =  `${this.checkInTitle} - ${this.checkOutTitle}`
          $('#datepicker-trigger').addClass('btn-outline-primary');
          $('#datepicker-trigger').removeClass('btn-primary');
        }

        if (dateOne) {
          formattedDates =  `${format(dateOne, this.dateFormat)} - ${this.checkOutTitle}`
          $('#datepicker-trigger').removeClass('btn-outline-primary');
          $('#datepicker-trigger').addClass('btn-primary');
        }

        if (dateTwo) {
          formattedDates = format(dateOne, this.dateFormat) + ' - ' + format(dateTwo, this.dateFormat)
        }

        $('.sm-check-in-out').text(formattedDates);
        return formattedDates
      },
      date_one_selected(val) {
        this.check_in = val
        $('.check_in').val(val);
      },
      date_two_selected(val) {
        this.check_out = val
        $('.check_out').val(val);
      },
      apply() {
        if ($('#standalone').val()) {
          Invoice.calculate([this.lodgingId])
        }
      },
      get_yesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d;
      }
    }
  }
</script>
