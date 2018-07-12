(->
  window.ChosenSelect or (window.ChosenSelect = {})

  ChosenSelect.init = ->
    $(".chosen-select").chosen()

).call this
