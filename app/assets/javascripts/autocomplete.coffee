(->
  window.Autocomplete or (window.Autocomplete = {})

  Autocomplete.init = (url) ->
    $('.autocomplete').typeahead { highlight: true }, {
      name: 'collections'
      display: 'name'
      limit: 4
      source: source(url, 'campaigns')
      templates: header: '<h4 class="category-name">Collections</h4>'
    }, {
      name: 'accommodations'
      displayKey: 'name'
      limit: 4
      source: source(url, 'lodgings')
      templates: header: '<h4 class="category-name">Accommodations</h4>'
    }

    $('.autocomplete').bind 'typeahead:selected', (obj, datum) ->
      if datum.type == 'lodging'
        window.location.href = "#{datum.url}?check_in=#{$('.check-in').val()}&check_out=#{$('.check-out').val()}"
      else if datum.type == 'campaign'
        window.location.href = datum.url

  source = (url, type) ->
    return new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{url}?query=%QUERY&type=#{type}"
        wildcard: '%QUERY')

).call this
