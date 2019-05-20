<template>
  <div class="dropdown guests-dropdown vue-guests-dropdown" :id="'vue-'+this.dropdownId">
    <button :class="this.buttonClasses" type="button" :id="this.dropdownId" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      <span class="title">{{ guests() }}</span>
    </button>

    <div class="dropdown-menu w-100" :aria-labelledby="this.dropdownId" @click="handleMenuClick">
      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-md-6 text-lg pt-2">Adults</label>
          <number-input-spinner
            :min="0"
            :max="99"
            :integerOnly="true"
            :inputClass="'vnis__input'"
            :buttonClass="'vnis__button col-md-6'"
            :value="this.totalAdults"
            @input="handleAdults"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-md-6 text-lg pt-2">Children</label>
          <number-input-spinner
            :min="0"
            :max="99"
            :integerOnly="true"
            @input="handleChildren"
            :inputClass="'vnis__input'"
            :value="this.totalChildren"
            :buttonClass="'vnis__button col-md-6'"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-md-6 text-lg pt-2">Infants</label>
          <number-input-spinner
            :min="0"
            :max="99"
            :integerOnly="true"
            @input="handleInfants"
            :inputClass="'vnis__input'"
            :value="this.totalInfants"
            :buttonClass="'vnis__button col-md-6'"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3" v-show="this.showApply">
        <input type="button" name="done" class="btn btn-sm btn-secondary float-right mr-0" value="Done" @click="handleButtonClick" />
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: "guests-dropdown",
    props: [
      'adults',
      'children',
      'infants',
      'adultsTarget',
      'childrenTarget',
      'infantsTarget',
      'dropdownId',
      'showApply',
      'buttonClasses',
      'submitTarget',
      'lodgingId',
    ],
    data() {
      return {
        totalAdults: this.adults ? this.adults : 0,
        totalChildren: this.children ? this.children : 0,
        totalInfants: this.infants ? this.infants : 0,
      }
    },
    mounted() {
    },
    methods: {
      handleAdults(value) {
        $(this.adultsTarget).val(value)
        this.totalAdults = value
      },
      handleChildren(value) {
        $(this.childrenTarget).val(value)
        this.totalChildren = value
      },
      handleInfants(value) {
        $(this.infantsTarget).val(value)
        this.totalInfants = value
      },
      guests() {
        var guestsTitle = "";

        if (this.totalAdults) {
          guestsTitle += this.totalAdults + " " + (this.totalAdults > 1 ? 'adults' : 'adult');
        }

        if (this.totalChildren) {
          guestsTitle += (this.totalAdults ? ', ' : ' ') + " " + this.totalChildren + " " + (this.totalChildren > 1 ? 'children' : 'child');
        }

        if (this.totalInfants) {
          guestsTitle += (this.totalChildren || this.totalAdults ? ', ' : ' ') + " " + this.totalInfants + " " + (this.totalInfants > 1 ? 'infants' : 'infant');
        }

        if(guestsTitle == "")
          return "Guests";
        else
          return guestsTitle;
      },
      handleMenuClick(e) {
        e.stopPropagation()
        e.preventDefault()
      },
      handleButtonClick() {
        $(`#vue-${this.dropdownId}`).dropdown("toggle");

        if(this.submitTarget && $(this.submitTarget).length > 0) {
          $('#loader').show();
          Rails.fire($(this.submitTarget).get(0), 'submit');
        }
        else if(this.lodgingId) {
          Invoice.calculate([this.lodgingId])
        }
      }
    }
  }
</script>

<style>
  .vnis .vnis__button {
    border-radius: 50%;
    background: none;
    border: 1px solid black;
    color: black;
  }

  .vnis .vnis__button:hover {
    background: none;
    border: 2px solid black;
    color: black;
  }

  .vnis .vnis__input {
    width: 50px;
    border: none;
  }

  .vue-guests-dropdown .dropdown-menu {
    min-width: 300px;
  }
</style>
