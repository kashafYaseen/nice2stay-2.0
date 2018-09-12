(->
  window.Autocomplete or (window.Autocomplete = {})

  Autocomplete.init = (url) ->
    $('.autocomplete').typeahead { highlight: true }, {
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
      limit: 4
      source: source(url, 'campaigns')
      templates:
        header: '<p class="category-name">Collections</p>'
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

    $('.autocomplete').bind 'typeahead:selected', (obj, datum) ->
      $('#homepage_search_form').attr('action', datum.url);

  source = (url, type) ->
    return new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{url}?query=%QUERY&type=#{type}"
        wildcard: '%QUERY')

  suggestion = (item) ->
    if item.thumbnail then src = item.thumbnail else src = 'https://imagesnice2stayeurope.s3.amazonaws.com/uploads/image/image/12105/thumb_tuscany.jpg'

    "<div>
      <div class='row'>
        <div class='col-2 my-auto'>
          <img src='#{src}' class='rounded-circle' />
        </div>

        <div class='col-10 p-sm-0 my-auto details'>
          #{strip_tags item.name} </br>
          <span class='font-italic text-xs'>#{strip_tags item.title}</span>
        </div>
      </div
    </div>"

  strip_tags = (str) ->
    if str
      return str.replace(/<[^>]+>/ig,'')
    return str

).call this
