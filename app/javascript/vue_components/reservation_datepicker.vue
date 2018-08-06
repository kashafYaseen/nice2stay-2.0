<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary btn-sm" id="datepicker-trigger">Dates {{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="'datepicker-trigger'"
        :date-one="check_in"
        :date-two="check_out"
        @date-one-selected="date_one_selected"
        @date-two-selected="date_two_selected"
        :inline="true"
        :disabled-dates="disabled_dates"
        :min-date="this.current_date.toString()"
        :months-to-show="1"
      ></airbnb-style-datepicker>
      <input type="hidden" name="reservation[check_in]" :value="check_in">
      <input type="hidden" name="reservation[check_out]" :value="check_out">
    </div>
  </div>
</template>

<script>
  import format from 'date-fns/format'

  export default {
    data() {
      let check_in = $('.persisted-data').data('check-in');
      let check_out = $('.persisted-data').data('check-out');
      let today = this.get_yesterday()
      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        disabled_dates: [],
        current_date: today,
        lodging_id: '',
      }
    },
    mounted() {
      this.lodging_id = this.$el.parentElement.dataset.lodgingId
      this.disabled_dates = JSON.parse(this.$el.parentElement.dataset.disabledDates)
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
      date_one_selected(val) {
        this.check_in = val
        calculate_bill(this.check_in, this.check_out, this.lodging_id);
      },
      date_two_selected(val) {
        this.check_out = val
        calculate_bill(this.check_in, this.check_out, this.lodging_id);
      },
      get_yesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d;
      }
    }
  }

  function calculate_bill(check_in, check_out, lodging_id) {
    if($("#calculate_bill").val() == 'true') {
      var values = [check_in,
        check_out,
        $('#reservation_adults').val(),
        $('#reservation_children').val(),
        $('#reservation_infants').val(),
        lodging_id
      ];

      Lodging.update_bill(values);
    }
  };
</script>
