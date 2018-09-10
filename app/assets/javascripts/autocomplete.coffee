(->
  window.Autocomplete or (window.Autocomplete = {})

  Autocomplete.init = (url) ->
    $('.autocomplete').typeahead { highlight: true }, {
      name: 'countries'
      displayKey: 'name'
      limit: 4
      source: source(url, 'countries')
      templates: header: '<p class="category-name">Countries</p>'
    }, {
      name: 'regions'
      displayKey: 'name'
      limit: 4
      source: source(url, 'regions')
      templates: header: '<p class="category-name">Regions</p>'
    }, {
      name: 'collections'
      display: 'name'
      limit: 4
      source: source(url, 'campaigns')
      templates: header: '<p class="category-name">Collections</p>'
    }, {
      name: 'accommodations'
      displayKey: 'name'
      limit: 10
      source: source(url, 'lodgings')
      templates: header: '<p class="category-name">Accommodations</p>'
    }

    $('.autocomplete').bind 'typeahead:selected', (obj, datum) ->
      if datum.type == 'lodging'
        window.location.href = "#{datum.url}?check_in=#{$('.check-in').val()}&check_out=#{$('.check-out').val()}"
      else
        window.location.href = datum.url

  source = (url, type) ->
    return new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{url}?query=%QUERY&type=#{type}"
        wildcard: '%QUERY')

).call this
