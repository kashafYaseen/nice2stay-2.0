(->
  window.ChosenSelect or (window.ChosenSelect = {})

  ChosenSelect.init = ->
    $(".chosen-select").chosen({ width: '100%' });

).call this
