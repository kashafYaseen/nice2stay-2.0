<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary w-100" id="datepicker-trigger">{{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="'datepicker-trigger'"
        :date-one="check_in"
        :date-two="check_out"
        @date-one-selected="date_one_selected"
        @date-two-selected="date_two_selected"
        @apply="apply"
        :inline="false"
        :months-to-show="1"
        :disabled-dates="disabled_dates"
        :min-date="this.current_date.toString()"
        :show-action-buttons="true"
      ></airbnb-style-datepicker>
    </div>
  </div>
</template>

<script>
  import format from 'date-fns/format'

  export default {
    data() {
      let check_in = $('.persisted-data').data('check-in');
      let check_out = $('.persisted-data').data('check-out');
      let months = $('.persisted-data').data('months');
      let today = this.get_yesterday();
      let check_in_title = $('.persisted-data').data('check-in-title');
      let check_out_title = $('.persisted-data').data('check-out-title');

      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        check_in_title: check_in_title ? check_in_title : 'check in',
        check_out_title: check_out_title ? check_out_title : 'check out',
        disabled_dates: [],
        current_date: today,
        lodging_id: '',
        months: months ? months : 1,
      }
    },
    mounted() {
      if(this.$el.parentElement.dataset.lodgingId)
        this.lodging_id = this.$el.parentElement.dataset.lodgingId

      if(this.$el.parentElement.dataset.disabledDates)
        this.disabled_dates = JSON.parse(this.$el.parentElement.dataset.disabledDates)
    },
    methods: {
      formatDates(dateOne, dateTwo) {
        let formattedDates = ''

        if (!dateTwo && !dateOne){
          formattedDates =  `${this.check_in_title} - ${this.check_out_title}`
          $('#datepicker-trigger').addClass('btn-outline-primary');
          $('#datepicker-trigger').removeClass('btn-primary');
        }

        if (dateOne) {
          formattedDates =  `${format(dateOne, this.dateFormat)} - ${this.check_out_title}`
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
          Invoice.calculate([this.lodging_id])
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
