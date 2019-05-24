<template>
  <div class="datepicker-trigger">
    <button :class="this.triggerButton" :id="this.triggerId">{{ formatDates(check_in, check_out) }}</button>
    <airbnb-style-datepicker
      :trigger-element-id="this.triggerId"
      :date-one="check_in"
      :date-two="check_out"
      @date-one-selected="date_one_selected"
      @date-two-selected="date_two_selected"
      :months-to-show="this.months"
      @apply="onApplyMethod"
      :inline="this.inline"
      :min-date="this.minDate"
      :disabled-dates="this.disabledDates"
      :show-action-buttons="this.actionButtons"
      :fullscreenMobile="this.fullScreen"
      :mobileHeader="'Nice2Stay'"
    ></airbnb-style-datepicker>
    <input type="hidden" name="check_in" class="check-in" :value="check_in">
    <input type="hidden" name="check_out" class="check-out" :value="check_out">
  </div>
</template>

<script>
  import format from 'date-fns/format'

  export default {
    name: "datepicker",
    props: ['monthsToShow', 'triggerId', 'columnClass', 'triggerButton', "checkIn", "checkOut", "months", "disabledDates", "minDate", "actionButtons", "fullScreen", "inline" ],

    data() {
      let check_in = this.checkIn
      let check_out = this.checkOut
      let months = this.months


      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        disabled_dates: [],
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
      date_one_selected(val) {
        this.check_in = val
        $('.check-in').val(val);
      },
      date_two_selected(val) {
        this.check_out = val
        $('.check-out').val(val);
      },
      onApplyMethod(e) {
        if($('.lodgings-filters').length > 0) {
          $('#loader').show();
          Rails.fire($('.lodgings-filters').get(0), 'submit');
        }
      }
    }
  }
</script>

<style scoped>
.asd__wrapper--full-screen {
  top: 74px;
}
</style>
 