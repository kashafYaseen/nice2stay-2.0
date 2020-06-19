<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary" :id="this.triggerId" :class="{ 'd-none': this.inline }">{{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="this.triggerId"
        :date-one="check_in"
        :date-two="check_out"
        @date-one-selected="date_one_selected"
        @date-two-selected="date_two_selected"
        @apply="apply"
        :inline="this.inline"
        :months-to-show="this.months"
        :disabled-dates="this.disabledDates"
        :customized-dates= "this.customizedDates"
        :min-date="this.minDate"
        :show-apply="true"
        :show-action-buttons="this.showActionButtons"
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
      "months",
      "lodgingId",
      "disabledDates",
      "customizedDates",
      "minDate",
      "invoiceOnApply",
      "triggerId",
      "showActionButtons",
      "inline",
      "highlightOnSelection",
      "bindWith"
    ],
    data() {
      let check_in = this.checkIn
      let check_out = this.checkOut

      return {
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        dateFormat: 'D MMM',
      }
    },
    mounted() {

    },
    methods: {
      formatDates(dateOne, dateTwo) {
        let formattedDates = ''

        if (!dateTwo && !dateOne) {
          formattedDates = `${I18n.t('search.check_in')} - ${I18n.t('search.check_out')}`
          if (this.highlightOnSelection) {
            $(`#${this.triggerId}`).addClass('btn-outline-primary');
            $(`#${this.triggerId}`).removeClass('btn-primary');
          }
        }

        if (dateOne) {
          formattedDates = `${format(dateOne, this.dateFormat)} - ${I18n.t('search.check_out')}`
          if (this.highlightOnSelection) {
            $(`#${this.triggerId}`).removeClass('btn-outline-primary');
            $(`#${this.triggerId}`).addClass('btn-primary');
          }
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

        this.apply()
      },
      apply() {
        if (this.invoiceOnApply ) {
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
