<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary btn-sm" id="trigger-range">Dates {{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="'trigger-range'"
        :date-one="check_in"
        :date-two="check_out"
        @date-one-selected="val => { check_in = val }"
        @date-two-selected="val => { check_out = val }"
        @apply="onApplyMethod"
        :min-date="this.yesterday"
      ></airbnb-style-datepicker>
      <input type="hidden" name="check_in" :value="check_in">
      <input type="hidden" name="check_out" :value="check_out">
    </div>
  </div>
</template>

<script>
  import format from 'date-fns/format'

  export default {
    data() {
      let check_in = $('.lodgings-filters').data('check-in');
      let check_out = $('.lodgings-filters').data('check-out');
      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        yesterday: this.getYesterday()
      }
    },
    methods: {
      formatDates(dateOne, dateTwo) {
        let formattedDates = ''
        if (dateOne) {
          formattedDates = format(dateOne, this.dateFormat)
        }
        if (dateTwo) {
          formattedDates += ' - ' + format(dateTwo, this.dateFormat)
        }
        return formattedDates
      },
      onApplyMethod(e) {
        $('#loader').show();
        Rails.fire($('.lodgings-filters').get(0), 'submit');
      },
      getYesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d.toString();
      }
    }
  }
</script>
