<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary d-none" id="datepicker-trigger"></button>
      <airbnb-style-datepicker
        :trigger-element-id="'datepicker-trigger'"
        :inline="true"
        :months-to-show="months"
        :disabled-dates="disabled_dates"
        :min-date="this.current_date.toString()"
        :show-action-buttons="false"
        :fullscreenMobile="true"
        :mobileHeader="'Nice2Stay'"
      ></airbnb-style-datepicker>
    </div>
  </div>
</template>

<script>
  import format from 'date-fns/format'

  export default {
    data() {
      let today = this.get_yesterday();
      let months = $('.persisted-data').data('months');

      return {
        dateFormat: 'D MMM',
        disabled_dates: [],
        current_date: today,
        months: months ? months : 2,
      }
    },
    mounted() {
      if(this.$el.parentElement.dataset.disabledDates)
        this.disabled_dates = JSON.parse(this.$el.parentElement.dataset.disabledDates)
    },
    methods: {
      get_yesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d;
      }
    }
  }
</script>
