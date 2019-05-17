<template>
  <div class="dropdown guests-dropdown">
    <button class="btn btn-outline-primary dropdown-toggle w-100" type="button" :id="this.dropdownID" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
      <span class="title">{{ guests() }}</span>
    </button>

    <div class="dropdown-menu w-100" :aria-labelledby="this.dropdownID">
      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-md-6 text-lg pt-2">Adults</label>
          <number-input-spinner
            :min="1"
            :integerOnly="true"
            :inputClass="'vnis__input'"
            :buttonClass="'vnis__button col-md-6'"
            @input="handleAdults"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-md-6 text-lg pt-2">Children</label>
          <number-input-spinner
            :min="0"
            :integerOnly="true"
            @input="handleChildren"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3">
        <div class="row">
          <label class="col-md-6 text-lg pt-2">Infants</label>
          <number-input-spinner
            :min="0"
            :integerOnly="true"
            @input="handleInfants"
          />
        </div>
      </div>

      <div class="dropdown-item mt-3 mb-3" v-show="this.showApply">
        <input type="button" name="done" class="btn btn-sm btn-secondary float-right mr-0" value="Done" />
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
      'dropdownID',
      'showApply'
    ],
    data() {
      let adults = this.adults
      let children = this.children
      let infants = this.infants

      return {
        totalAdults: adults ? adults : 0,
        totalChildren: children ? children : 0,
        totalInfants: infants ? infants : 0,
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
        return `${this.totalAdults} Adults, ${this.totalChildren} Children, ${this.totalInfants} Infants`
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
</style>
