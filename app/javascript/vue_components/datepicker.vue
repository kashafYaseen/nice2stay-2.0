<template>
  <div :class="this.columnClass">
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary btn-sm" :class="this.columnClass" :id="this.triggerId">{{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="this.triggerId"
        :date-one="check_in"
        :date-two="check_out"
        @date-one-selected="val => { check_in = val }"
        @date-two-selected="val => { check_out = val }"
        :months-to-show="this.monthsToShow"
        @apply="onApplyMethod"
        :min-date="this.yesterday"
      ></airbnb-style-datepicker>
      <input type="hidden" name="check_in" class="check-in" :value="check_in">
      <input type="hidden" name="check_out" class="check-out" :value="check_out">
    </div>
  </div>
</template>

<script>
  import format from 'date-fns/format'

  export default {
    props: ['monthsToShow', 'triggerId', 'columnClass'],

    data() {
      let check_in = $('.lodgings-filters').data('check-in');
      let check_out = $('.lodgings-filters').data('check-out');
      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        yesterday: this.getYesterday(),
      }
    },
    methods: {
      formatDates(dateOne, dateTwo) {
        let formattedDates = ''
        if (!dateTwo && !dateOne){
          formattedDates =  'Dates'
          $(`#${this.triggerId}`).addClass('btn-outline-primary');
          $(`#${this.triggerId}`).removeClass('btn-primary');
        }

        if (dateOne) {
          formattedDates = format(dateOne, this.dateFormat)
          $(`#${this.triggerId}`).removeClass('btn-outline-primary');
          $(`#${this.triggerId}`).addClass('btn-primary');
        }
        if (dateTwo) {
          formattedDates += ' - ' + format(dateTwo, this.dateFormat)
        }

        return formattedDates
      },
      onApplyMethod(e) {
        if($('.lodgings-filters').length > 0) {
          $('#loader').show();
          Rails.fire($('.lodgings-filters').get(0), 'submit');
        }
      },
      getYesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d.toString();
      }
    }
  }
</script>

<style scoped>
.asd__wrapper--full-screen {
  top: 74px;
}
</style>
