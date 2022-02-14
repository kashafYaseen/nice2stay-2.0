<template>
  <div class="dropdown guests-dropdown vue-guests-dropdown" :id="'vue-'+this.dropdownId" ref="vuedropdwon">
    <button :class="this.buttonClasses" type="button" :id="this.dropdownId" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      <span class="title">{{ guests() }}</span>
    </button>

    <div :class="inline ? 'position-relative' : 'dropdown-menu'" class="w-100" :aria-labelledby="this.dropdownId" @click="handleMenuClick">
      <div :class="inline ? '' : 'dropdown-item'" class="mt-3 mb-3">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ adultsTitle() }}</label>
          <div :class="inline ? 'vnis mx-auto' : 'vnis'">
            <button :class="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'" type="button" @click="updateAdults('decrement')">-</button>
            <input :class="inline ? 'vnis__input bg-secondary-dark' : 'vnis__input'" type="text" v-model="totalAdults" />
            <button :class="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'" type="button" @click="updateAdults()">+</button>
          </div>
        </div>
      </div>

      <div :class="inline ? '' : 'dropdown-item'" class="mt-3 mb-3">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ childrenTitle() }}<br><span class="text-xxs text-capitalize">{{ childrenAges() }}</span></label>
          <div :class="inline ? 'vnis mx-auto' : 'vnis'">
            <button :class="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'" type="button" @click="updateChildren('decrement')">-</button>
            <input :class="inline ? 'vnis__input bg-secondary-dark' : 'vnis__input'" type="text" v-model="totalChildren" />
            <button :class="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'" type="button" @click="updateChildren()">+</button>
          </div>
        </div>
      </div>

      <div :class="inline ? '' : 'dropdown-item'" class="mt-3 mb-3" v-if="this.showInfants">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ infantsTitle() }}</label>
          <number-input-spinner
            :min="0"
            :max="12"
            :integerOnly="true"
            @input="handleInfants"
            :inputClass="inline ? 'vnis__input bg-secondary-dark' : 'vnis__input'"
            :value="this.totalInfants"
            :buttonClass="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'"
            :class="inline ? 'mx-auto' : ''"
          />
        </div>
      </div>

      <div :class="inline ? '' : 'dropdown-item'" class="mt-3 mb-3" v-if="this.showBeds">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ bedsTitle() }}</label>
          <number-input-spinner
            :min="0"
            :max="10"
            :integerOnly="true"
            @input="handleBeds"
            :inputClass="inline ? 'vnis__input bg-secondary-dark' : 'vnis__input'"
            :value="this.totalBeds"
            :buttonClass="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'"
            :class="inline ? 'mx-auto' : ''"
          />
        </div>
      </div>

      <div :class="inline ? '' : 'dropdown-item'" class="mt-3 mb-3" v-if="this.showBaths">
        <div class="row">
          <label class="col-6 text-lg pt-2">{{ bathsTitle() }}</label>
          <number-input-spinner
            :min="0"
            :max="12"
            :integerOnly="true"
            @input="handleBaths"
            :inputClass="inline ? 'vnis__input bg-secondary-dark' : 'vnis__input'"
            :value="this.totalBaths"
            :buttonClass="inline ? 'vnis__button col-6 bg-white' : 'vnis__button col-6'"
            :class="inline ? 'mx-auto' : ''"
          />
        </div>
      </div>

      <div :class="inline ? '' : 'dropdown-item'" class="mt-3 mb-3" v-show="this.showApply">
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
      beds: {
        type: Number,
        default: 0,
      },
      baths: {
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
      bedsTarget:{
        type: String
      },
      bathsTarget:{
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
      showBeds: {
        type: Boolean,
        default: false
      },
      showBaths: {
        type: Boolean,
        default: false
      },
      highlightOnSelection: {
        type: Boolean,
        default: false
      },
      inline: {
        type: Boolean,
        default: false
      },
      bindWith: {
        type: String
      },
      titleSuffix: {
        type: String,
        default: ''
      },
      lodgingIds: {
        type: Array
      }
    },
    data() {
      return {
        totalAdults: this.adults ? this.adults : 0,
        totalChildren: this.children ? this.children : 0,
        totalInfants: this.infants ? this.infants : 0,
        totalBeds: this.beds ? this.beds : 0,
        totalBaths: this.baths ? this.baths : 0,
        maxCalculatedChildren: (this.maxAdults - this.totalAdults) + this.maxChildren,
      }
    },
    mounted() {
      $(this.$refs.vuedropdwon).on("hide.bs.dropdown", this.handleDropdownClose)
      this.guests()
    },
    methods: {
      updateAdults(operation = 'increment') {
        if (operation == 'increment') {
          if (this.totalAdults >= 0 && this.totalAdults < this.maxAdults) this.totalAdults += 1
        } else {
          if (this.totalAdults > 0 && this.totalAdults <= this.maxAdults) this.totalAdults -= 1
        }
        $(this.adultsTarget).val(this.totalAdults)
      },
      updateChildren(operation = 'increment') {
        if (operation == 'increment') {
          if (this.totalChildren >= 0 && this.totalChildren < (this.maxChildren + this.maxAdults)) this.totalChildren += 1
        } else {
          if (this.totalChildren > 0 && this.totalChildren <= (this.maxChildren + this.maxAdults)) this.totalChildren -= 1
        }
        $(this.childrenTarget).val(this.totalChildren)
      },
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
      handleBeds(value) {
        $(this.bedsTarget).val(value)
        this.totalBeds = value
      },
      handleBaths(value) {
        $(this.bathsTarget).val(value)
        this.totalBaths = value
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

          return "Guests" + this.titleSuffix;
        }
        else {
          if (this.highlightOnSelection) {
            $(`#${this.dropdownId}`).removeClass('btn-outline-primary');
            $(`#${this.dropdownId}`).addClass('btn-primary');
          }

          return guestsTitle + this.titleSuffix;
        }
      },
      handleMenuClick(e) {
        e.stopPropagation()
        e.preventDefault()
      },
      handleButtonClick() {
        if(!this.inline)
          $(`#vue-${this.dropdownId}`).dropdown("toggle");

        if(this.submitTarget && $(this.submitTarget).length > 0) {
          $('#loader').show();
          Rails.fire($(this.submitTarget).get(0), 'submit');
        }
        else if(this.lodgingId) {
          Invoice.calculate([this.lodgingId])
        }
      },

      handleDropdownClose() {
        if(this.submitTarget && $(this.submitTarget).length > 0) {
          $('#loader').show();
          Rails.fire($(this.submitTarget).get(0), 'submit');
        }
        else if(this.lodgingId) {
          Invoice.calculate([this.lodgingId])
        }
        else if (this.lodgingIds) {
         Invoice.calculate(this.lodgingIds)
        }
      },
      adultsTitle() {
        return I18n.t('search.adults')
      },
      childrenTitle() {
        return I18n.t('search.children_1')
      },
      bedsTitle() {
        return I18n.t('search.bedrooms')
      },
      bathsTitle() {
        return I18n.t('search.bathrooms')
      },
      childrenAges() {
        return I18n.t('search.child_age');
      },
      infantsTitle() {
        return I18n.t('search.babies')
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
