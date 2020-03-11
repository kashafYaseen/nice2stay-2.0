(->
  window.Autocomplete or (window.Autocomplete = {})

  Autocomplete.init = (url) ->
    $('.autocomplete-general').typeahead { highlight: true }, {
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

    $('.autocomplete-general').bind 'typeahead:selected', (obj, datum) ->
      if datum.type == 'campaign'
        $('#homepage_search_form, #searchbar_search_form').attr('method', 'post')
      else if datum.type == 'country'
        $('.autocomplete-country').val(datum.country)
        $('.autocomplete-region').val('')
        $('.autocomplete').val('')
      else if datum.type == 'region'
        $('.autocomplete-region').val(datum.region)
        $('.autocomplete-country').val('')
        $('.autocomplete').val('')
      $('#homepage_search_form, #searchbar_search_form').attr('action', datum.url)

      if !$(this).data('skip-submission')
        $('#homepage_search_form, #searchbar_search_form').submit()

  Autocomplete.init_search = (url) ->
    $('.filters-autocomplete').typeahead { highlight: true }, {
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
      name: 'accommodations'
      displayKey: 'name'
      limit: 5
      source: source(url, 'lodgings')
      templates:
        header: '<p class="category-name">Accommodations</p>'
        suggestion: (lodging) -> suggestion(lodging)
    }

    $('.filters-autocomplete').bind 'typeahead:change', (obj, datum) ->
      if $('.lodgings-filters #region').val() || $('.lodgings-filters #country').val()
        $('.lodgings-filters #name_middle').val('')

    $('.filters-autocomplete').bind 'typeahead:selected', (obj, datum) ->
      if datum.type == 'country'
        $("#countries_#{datum.id}").prop('checked', true)

        $('.lodgings-filters #country').val('')
        $('.lodgings-filters #region').val('')
        $('.lodgings-filters #bounds').val('')
        $('.lodgings-filters #name_middle').val('')
      else if datum.type == 'region'
        $("#regions_#{datum.id}").prop('checked', true)

        $('.lodgings-filters #country').val('')
        $('.lodgings-filters #region').val('')
        $('.lodgings-filters #bounds').val('')
        $('.lodgings-filters #name_middle').val('')
      else
        $('.lodgings-filters #country').val('')
        $('.lodgings-filters #region').val('')
        $('.lodgings-filters #bounds').val('')
        $('.lodgings-filters #name_middle').val(datum.name)
      Url.update("");
      Filters.submit()

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
