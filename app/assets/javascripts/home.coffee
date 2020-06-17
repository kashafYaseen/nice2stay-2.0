(->
  window.Home or (window.Home = {})

  Home.init = (url) ->
    $('.autocomplete-home').typeahead { highlight: true }, {
      name: 'countries'
      displayKey: 'name'
      limit: 4
      source: source(url, 'countries')
      templates:
        header: '<p class="category-name">Countries</p>',
        suggestion: (country) -> suggestion(country)
    }, {
      name: 'regions'
      displayKey: 'name'
      limit: 4
      source: source(url, 'regions')
      templates:
        header: '<p class="category-name">Regions</p>'
        suggestion: (region) -> suggestion(region)
    }, {
      name: 'collections'
      displayKey: 'name'
      limit: 10
      source: source(url, 'campaigns')
      templates:
        header: '<p class="category-name darken">Popular Collections</p>'
        suggestion: (collection) -> suggestion(collection)
    }, {
      name: 'accommodations'
      displayKey: 'name'
      limit: 5
      source: source(url, 'lodgings')
      templates:
        header: '<p class="category-name">Accommodations</p>'
        suggestion: (lodging) -> suggestion(lodging)
    }

    $('.autocomplete-home').bind 'typeahead:selected', (obj, datum) ->
      if datum.type == 'country'
        $('.regions-list .region').each (index, region) ->
          $(region).prop('checked', false)
        $('.countries-list .country').each (index, country) ->
          $(country).prop('checked', false)

        $("#countries_#{datum.id}").prop('checked', true)
      else if datum.type == 'region'
        $('.countries-list .country').each (index, country) ->
          $(country).prop('checked', false)
        $('.regions-list .region').each (index, region) ->
          $(region).prop('checked', false)

        $("#regions_#{datum.id}").prop('checked', true)

  source = (url, type) ->
    return new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{url}?query=%QUERY&type=#{type}"
        wildcard: '%QUERY')

  suggestion = (item) ->
    "<div>
      <div class='row'>
        <div class='col-12'>
          #{remove_strip_tags item.name} </br>
        </div>
      </div
    </div>"

  remove_strip_tags = (str) ->
    if str
      return str.replace(/<[^>]+>/ig,'')
    return str

).call this
