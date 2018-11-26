(->
  window.Autocomplete or (window.Autocomplete = {})

  Autocomplete.init = (url) ->
    $('.autocomplete').typeahead { highlight: true }, {
      name: 'countries'
      displayKey: 'name'
      limit: 4
      source: source(url, 'countries')
      templates:
        header: '<p class="category-name text-sm">Countries</p>',
        suggestion: (country) -> suggestion(country)
    }, {
      name: 'regions'
      displayKey: 'name'
      limit: 4
      source: source(url, 'regions')
      templates:
        header: '<p class="category-name text-sm">Regions</p>'
        suggestion: (region) -> suggestion(region)
    }, {
      name: 'collections'
      displayKey: 'name'
      limit: 10
      source: source(url, 'campaigns')
      templates:
        header: '<p class="category-name text-sm darken">Collections</p>'
        suggestion: (collection) -> suggestion(collection)
    }, {
      name: 'accommodations'
      displayKey: 'name'
      limit: 3
      source: source(url, 'lodgings')
      templates:
        header: '<p class="category-name text-sm">Accommodations</p>'
        suggestion: (lodging) -> suggestion(lodging)
    }

    $('.autocomplete').bind 'typeahead:selected', (obj, datum) ->
      if datum.type == 'campaign'
        $('#homepage_search_form').attr('method', 'post')
      $('#homepage_search_form').attr('action', datum.url)

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
          #{if item.type == 'lodging' then "<span class='font-italic text-xxs'>#{remove_strip_tags item.title}</span>" else ""}
        </div>
      </div
    </div>"

  remove_strip_tags = (str) ->
    if str
      return str.replace(/<[^>]+>/ig,'')
    return str

).call this
