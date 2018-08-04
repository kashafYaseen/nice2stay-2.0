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
      let check_in = $('.persisted-data').data('check-in');
      let check_out = $('.persisted-data').data('check-out');
      let today = this.get_yesterday()
      return {
        dateFormat: 'D MMM',
        check_in: check_in ? check_in : '',
        check_out: check_out ? check_out : '',
        id: "reservation-trigger-range-",
        disabled_dates: [],
        current_date: today,
        child_id: '',
        flag_id: ''
      }
    },
    mounted() {
      this.child_id = this.$el.parentElement.dataset.childId
      this.flag_id = this.$el.parentElement.dataset.flagId
      this.id = `reservation-trigger-range-${this.child_id}`
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
        $('#wishlist_check_in').val(val);
        calculate_bill(this.check_in, this.check_out, this.child_id, this.flag_id);
      },
      date_two_selected(val) {
        this.check_out = val
        $('#wishlist_check_out').val(val);
        calculate_bill(this.check_in, this.check_out, this.child_id, this.flag_id);
      },
      get_yesterday() {
        var d = new Date();
        d.setDate(d.getDate() - 1);
        return d;
      }
    }
  }

  function calculate_bill(check_in, check_out, child_id, flag_id) {
    if($(flag_id).val() == 'true') {
      var values = [check_in,
        check_out,
        $(`#reservation_adults_${child_id}`).val(),
        $(`#reservation_children_${child_id}`).val(),
        $(`#reservation_infants_${child_id}`).val(),
        child_id
      ];

      Lodging.update_bill(values);
    }
  };
</script>
