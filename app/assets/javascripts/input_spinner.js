/**
 * Author: Stefan Haack (https://github.com/shaack)
 * License: MIT, see file 'LICENSE'
 */

(function ($) {
    "use strict";
    $.fn.InputSpinner = function (options) {

        var config = {
            decrementButton: "<strong>-</strong>", // button text
            incrementButton: "<strong>+</strong>", // ..
            groupClass: "input-group-spinner", // css class of the input-group
            buttonsClass: "btn-outline-secondary",
            buttonsWidth: "2.5em",
            textAlign: "center",
            autoDelay: 500, // ms holding before auto value change
            autoInterval: 100, // speed of auto value change
            boostThreshold: 15, // boost after these steps
            boostMultiplier: 4,
            locale: null // the locale for number rendering; if null, the browsers language is used
        };
        Object.assign(config, options);

        var html = '<div class="input-spinner-group ' + config.groupClass + '">' +
            '<div class="input-group-prepend">' +
            '<button style="min-width: ' + config.buttonsWidth + '" class="input-spinner-btn btn-decrement ' + config.buttonsClass + '" type="button">' + config.decrementButton + '</button>' +
            '</div>' +
            '<input type="text" style="text-align: ' + config.textAlign + '" class="input-spinner-form" disabled/>' +
            '<div class="input-group-append">' +
            '<button style="min-width: ' + config.buttonsWidth + '" class="input-spinner-btn btn-increment ' + config.buttonsClass + '" type="button">' + config.incrementButton + '</button>' +
            '</div>' +
            '</div>';

        var locale = config.locale || navigator.language || "en-US";

        this.each(function () {

            var $original = $(this);
            $original.hide();

            var autoDelayHandler = null;
            var autoIntervalHandler = null;

            var $inputGroup = $(html);
            var $buttonDecrement = $inputGroup.find(".btn-decrement");
            var $buttonIncrement = $inputGroup.find(".btn-increment");
            var $input = $inputGroup.find("input");

            var min = parseFloat($original.prop("min")) || 0;
            var max = parseFloat($original.prop("max")) || Infinity;
            var step = parseFloat($original.prop("step")) || 1;
            var decimals = parseInt($original.attr("data-decimals")) || 0;

            var numberFormat = new Intl.NumberFormat(locale, {minimumFractionDigits: decimals});
            var value = parseFloat($original.val());

            if($original.prop("class").indexOf("is-invalid") !== -1) {
                $input.addClass("is-invalid");
            }
            if($original.prop("class").indexOf("is-valid") !== -1) {
                $input.addClass("is-valid");
            }
            if($original.prop("required")) {
                $input.prop("required", true);
            }
            if($original.prop("placeholder")) {
                $input.prop("placeholder", $original.prop("placeholder"));
            }

            $original.after($inputGroup);

            if(isNaN(value)) {
                $original.val("");
                $input.val("");
            } else {
                $original.val(value);
                $input.val(numberFormat.format(value));
            }

            var boostCount = 0;

            $input.on("paste keyup change", function () {
                var inputValue = $input.val();
                if (locale === "en-US" || locale === "en-GB" || locale === "th-TH") {
                    value = parseFloat(inputValue);
                } else {
                    value = parseFloat(inputValue.replace(/[. ]/g, '').replace(/,/g, '.')); // i18n
                }
                if(isNaN(value)) {
                    $original.val("");
                } else {
                    $original.val(value);
                }
            });

            onPointerDown($buttonDecrement[0], function () {
                stepHandling(-step);
            });

            onPointerDown($buttonIncrement[0], function () {
                stepHandling(step);
            });

            onPointerUp(document.body, function () {
                resetTimer();
            });

            function stepHandling(step) {
                calcStep(step);
                resetTimer();
                autoDelayHandler = setTimeout(function () {
                    autoIntervalHandler = setInterval(function () {
                        if (boostCount > config.boostThreshold) {
                            calcStep(step * config.boostMultiplier);
                        } else {
                            calcStep(step);
                        }
                        boostCount++;
                    }, config.autoInterval);
                }, config.autoDelay);
            }

            function calcStep(step) {
                if(isNaN(value)) {
                    value = 0;
                }
                value = Math.round(value / step) * step;
                value = Math.min(Math.max(value + step, min), max);
                $input.val(numberFormat.format(value));
                $original.val(Math.round(value * Math.pow(10, decimals)) / Math.pow(10, decimals));
            }

            function resetTimer() {
                boostCount = 0;
                clearTimeout(autoDelayHandler);
                clearTimeout(autoIntervalHandler);
            }

        });

    };

    function onPointerUp(element, callback) {
        element.addEventListener("mouseup", function (e) {
            callback(e);
        });
        element.addEventListener("touchend", function (e) {
            callback(e);
        });
    }

    function onPointerDown(element, callback) {
        element.addEventListener("mousedown", function (e) {
            e.preventDefault();
            callback(e);

            if($('#calculate_bill').val() == 'true') {
                var values = [$("input[name='reservation[check_in]']").val(),
                  $("input[name='reservation[check_out]']").val(),
                  $('#reservation_adults').val(),
                  $('#reservation_children').val(),
                  $('#reservation_infants').val()
                ];
                Lodging.update_bill(values);
            }
        });
        element.addEventListener("touchstart", function (e) {
            e.preventDefault();
            callback(e);
        });
    }

}(jQuery));
