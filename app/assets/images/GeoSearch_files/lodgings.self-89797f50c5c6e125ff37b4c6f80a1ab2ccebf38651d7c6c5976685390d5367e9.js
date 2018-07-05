(function() {
  (function() {
    var check_values, validate;
    window.Lodging || (window.Lodging = {});
    check_values = function(value) {
      return value === '';
    };
    Lodging.init = function() {
      Slider.init();
      $('.lodging_type').change(function() {
        return $(this).parents('form').submit();
      });
      return $('.lowest-price, .highest-price').click(function() {
        if ($(this).hasClass('lowest-price')) {
          $('#order').val('price_asc');
        } else if ($(this).hasClass('highest-price')) {
          $('#order').val('price_desc');
        }
        return $(this).parents('form').submit();
      });
    };
    Lodging.update_bill = function(values) {
      if (values.some(check_values)) {
        $('#lbl-error').text('Please select dates & guest details');
        return $('#bill').text('');
      } else {
        $('#lbl-error').text('');
        return $.ajax({
          url: ($('#lodging-url').data('url')) + "?values=" + values,
          type: 'GET',
          success: function(data) {
            var discount, result, total;
            result = "";
            total = 0;
            validate(values);
            $.each(data.rates, function(key, value) {
              result += "<b>€ " + key + " x " + value + " night</b>";
              return total += key * value;
            });
            if (data.discount) {
              discount = total * data.discount / 100;
              result += "<p>Discount " + data.discount + "% : $" + discount + "</p>";
              total -= discount;
            }
            if (total > 0) {
              result += "<p>total: " + total + "</p>";
              return $('#bill').html(result);
            } else {
              return $('#bill').text('Lodging not available.');
            }
          }
        });
      }
    };
    return validate = function(values) {
      values.push($('#reservation_lodging_id').val());
      return $.ajax({
        url: "/reservations/validate?values=" + values,
        type: 'GET',
        success: function(data) {}
      });
    };
  }).call(this);

}).call(this);
