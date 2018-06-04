<template>
  <div>
    <div class="datepicker-trigger">
      <button class="btn btn-outline-primary btn-sm" :id="id">Dates {{ formatDates(check_in, check_out) }}</button>
      <airbnb-style-datepicker
        :trigger-element-id="this.id"
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
      let check_in = $('#new_reservation').data('check-in');
      let check_out = $('#new_reservation').data('check-out');
      let today = this.get_yesterday()
      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        id: "reservation-trigger-range-",
        disabled_dates: [],
        current_date: today
      }
    },
    mounted() {
      this.id = "reservation-trigger-range-"+ this._uid
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
      date_one_selected(val) {
        this.check_in = val
        calculate_bill(this.check_in, this.check_out);
      },
      date_two_selected(val) {
        this.check_out = val
        calculate_bill(this.check_in, this.check_out);
      },
      get_yesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d;
      }
    }
  }

  function calculate_bill(check_in, check_out) {
    if($('#calculate_bill').val() == 'true') {
      var values = [check_in,
        check_out,
        $('#reservation_adults').val(),
        $('#reservation_children').val(),
        $('#reservation_infants').val()
      ];

      Lodging.update_bill(values);
    }
  };
</script>
