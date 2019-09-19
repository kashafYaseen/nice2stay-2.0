<template>
  <div class="dropdown guests-dropdown vue-guests-dropdown" :id="'vue-'+this.dropdownId">
    <button :class="this.buttonClasses" type="button" :id="this.dropdownId" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      <span class="title">{{ guests() }}</span>
    </button>

    <div class="dropdown-menu w-100" :aria-labelledby="this.dropdownId" @click="handleMenuClick">
      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ adultsTitle() }}</label>
          <number-input-spinner
            :min="0"
            :max="this.maxAdults"
            :integerOnly="true"
            :inputClass="'vnis__input'"
            :buttonClass="'vnis__button col-6'"
            :value="this.totalAdults"
            @input="handleAdults"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ childrenTitle() }}</label>
          <number-input-spinner
            :min="0"
            :max="this.maxCalculatedChildren"
            :integerOnly="true"
            @input="handleChildren"
            :inputClass="'vnis__input'"
            :value="this.totalChildren"
            :buttonClass="'vnis__button col-6'"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3" v-if="this.showInfants">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ infantsTitle() }}</label>
          <number-input-spinner
            :min="0"
            :max="this.maxInfants"
            :integerOnly="true"
            @input="handleInfants"
            :inputClass="'vnis__input'"
            :value="this.totalInfants"
            :buttonClass="'vnis__button col-6'"
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
    props: {
      adults: {
        type: Number,
        default: 0,
      },
      children: {
        type: Number,
        default: 0,
      },
      infants: {
        type: Number,
        default: 0,
      },
      adultsTarget:{
        type: String
      },
      childrenTarget:{
        type: String
      },
      infantsTarget:{
        type: String
      },
      dropdownId: {
        type: String,
        required: true
      },
      showApply: {
        type: Boolean,
        default: false
      },
      buttonClasses: {
        type: String
      },
      submitTarget: {
        type: String
      },
      lodgingId: {
        type: Number
      },
      maxAdults: {
        type: Number,
        default: 30
      },
      maxChildren: {
        type: Number,
        default: 30
      },
      maxInfants: {
        type: Number,
        default: 30
      },
      showInfants: {
        type: Boolean,
        default: true
      },
      highlightOnSelection: {
        type: Boolean,
        default: false
      },
      bindWith: {
        type: String
      }
    },
    data() {
      return {
        totalAdults: this.adults ? this.adults : 0,
        totalChildren: this.children ? this.children : 0,
        totalInfants: this.infants ? this.infants : 0,
        maxCalculatedChildren: (this.maxAdults - this.totalAdults) + this.maxChildren,
      }
    },
    mounted() {
      this.guests()
    },
    methods: {
      handleAdults(value) {
        $(this.adultsTarget).val(value)
        this.totalAdults = value
        this.maxCalculatedChildren = (this.maxAdults - this.totalAdults) + this.maxChildren
        if(this.totalChildren > this.maxCalculatedChildren)
          this.handleChildren(this.maxCalculatedChildren)

        if (this.bindWith)
          window[this.bindWith].$children[0].totalAdults = value
      },
      handleChildren(value) {
        $(this.childrenTarget).val(value)
        this.totalChildren = value
        if (this.bindWith)
          window[this.bindWith].$children[0].totalChildren = value
      },
      handleInfants(value) {
        $(this.infantsTarget).val(value)
        this.totalInfants = value
        if (this.bindWith)
          window[this.bindWith].$children[0].totalInfants = value
      },
      guests() {
        var guestsTitle = "";

        if (this.totalAdults) {
          guestsTitle += `${this.totalAdults} ${this.adultsTitle()}`
        }

        if (this.totalChildren) {
          guestsTitle += `${(this.totalAdults ? ', ' : ' ')} ${this.totalChildren} ${this.childrenTitle()}`
        }

        if (this.totalInfants) {
          guestsTitle += `${(this.totalChildren || this.totalAdults ? ', ' : ' ')} ${this.totalInfants} ${this.infantsTitle()}`
        }

        if(guestsTitle == "") {
          if (this.highlightOnSelection) {
            $(`#${this.dropdownId}`).addClass('btn-outline-primary');
            $(`#${this.dropdownId}`).removeClass('btn-primary');
          }

          return "Guests";
        }
        else {
          if (this.highlightOnSelection) {
            $(`#${this.dropdownId}`).removeClass('btn-outline-primary');
            $(`#${this.dropdownId}`).addClass('btn-primary');
          }

          return guestsTitle;
        }
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
      },
      adultsTitle() {
        return this.totalAdults > 1 ? 'adults' : 'adult'
      },
      childrenTitle() {
        return this.totalChildren > 1 ? 'children' : 'child'
      },
      infantsTitle() {
        return this.totalInfants > 1 ? 'infants' : 'infant'
      }
    }
  }
</script>

<style>
  .vue-guests-dropdown .vnis .vnis__button {
    border-radius: 50%;
    background: none;
    border: 1px solid black;
    color: black;
    width: 40px;
  }

  .vue-guests-dropdown .vnis .vnis__button:hover {
    background: none;
    border: 2px solid black;
    color: black;
  }

  .vue-guests-dropdown .vnis .vnis__input {
    width: 50px;
    border: none;
  }

  .vue-guests-dropdown .dropdown-menu {
    min-width: 300px;
  }
</style>
