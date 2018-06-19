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
        :inline="true"
        :months-to-show="1"
        :disabled-dates="disabled_dates"
        :min-date="this.current_date.toString()"
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
      let check_in = $('#dates-form').data('check-in');
      let check_out = $('#dates-form').data('check-out');
      let yesterday = this.get_yesterday()
      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        disabled_dates: [],
        current_date: yesterday
      }
    },
    mounted() {
      this.disabled_dates = $('#lodging-url').data('disabled-dates');
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
      get_yesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d;
      }
    }
  }
</script>
