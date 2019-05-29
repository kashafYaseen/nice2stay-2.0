<template>
  <div class="vue-guests-inline" @click="handleMenuClick">
    <div class="row">
      <label class="col-md-6 text-lg pt-2">Adults</label>
      <number-input-spinner
        :min="0"
        :max="this.maxAdults"
        :integerOnly="true"
        :inputClass="'vnis__input'"
        :buttonClass="'vnis__button col-md-6'"
        :value="this.totalAdults"
        @input="handleAdults"
      />
    </div>

    <div class="row">
      <label class="col-md-6 text-lg pt-2">Children</label>
      <number-input-spinner
        :min="0"
        :max="this.maxCalculatedChildren"
        :integerOnly="true"
        @input="handleChildren"
        :inputClass="'vnis__input'"
        :value="this.totalChildren"
        :buttonClass="'vnis__button col-md-6'"
      />
    </div>

    <div class="row">
      <label class="col-md-6 text-lg pt-2">Infants</label>
      <number-input-spinner
        :min="0"
        :max="this.maxInfants"
        :integerOnly="true"
        @input="handleInfants"
        :inputClass="'vnis__input'"
        :value="this.totalInfants"
        :buttonClass="'vnis__button col-md-6'"
      />
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
    },
    data() {
      return {
        totalAdults: this.adults ? this.adults : 0,
        totalChildren: this.children ? this.children : 0,
        totalInfants: this.infants ? this.infants : 0,
        maxCalculatedChildren: (this.maxAdults - this.totalAdults) + this.maxChildren
      }
    },
    methods: {
      handleAdults(value) {
        $(this.adultsTarget).val(value)
        this.totalAdults = value
        this.maxCalculatedChildren = (this.maxAdults - this.totalAdults) + this.maxChildren
        if(this.totalChildren > this.maxCalculatedChildren)
          this.handleChildren(this.maxCalculatedChildren)
      },
      handleChildren(value) {
        $(this.childrenTarget).val(value)
        this.totalChildren = value
      },
      handleInfants(value) {
        $(this.infantsTarget).val(value)
        this.totalInfants = value
      },
      handleMenuClick(e) {
        e.stopPropagation()
        e.preventDefault()
      }
    }
  }
</script>

<style>
  .vue-guests-inline .vnis .vnis__button {
    border-radius: 4px;
    background: none;
    border: 1px solid #ccc;
    color: black;
    width: 40px;
    height: 35px;
  }

  .vue-guests-inline .vnis .vnis__button:hover {
    background: none;
    border: 1px solid black;
    color: black;
  }

  .vue-guests-inline .vnis .vnis__input {
    width: 40px;
    height: 35px;
    border: none;
  }
</style>
