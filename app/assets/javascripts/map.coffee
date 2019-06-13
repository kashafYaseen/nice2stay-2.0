(->
  window.Map or (window.Map = {})

  Map.init = ->
    if $('#map').length
      L.mapbox.accessToken = 'pk.eyJ1IjoibmljZTJzdGF5IiwiYSI6ImNqcmx5bzN4MzA3NnQ0OW1vb25oNWZpYnQifQ.M-2JMwQg14gQzFxBDivSIg'
      map = window.map = L.mapbox.map 'map', 'mapbox.streets', touchZoom: false, scrollWheelZoom: false
      map.setView [38.5816, -121.4944], 12
      window.markers = markers = L.mapbox.featureLayer().addTo(map)._leaflet_id
      bounds_changed = window.bounds_changed = false
      Map.add_markers()
      Map.highlight_lodgings()

      DragControl = L.Control.extend(
        options: position: 'topleft'
        onAdd: (map) ->
          container = L.DomUtil.create('div', 'map-searchbox-control bg-white leaflet-bar')
          radiobuttons = "<input type='checkbox' name='search-on-drag' value='true' class='search-on-drag leaflet-control mt-1' checked/><label for='search-on-drag' class='search-on-drag-label'>Search if I move map</label><br>"
          $(container).html(radiobuttons)
          container
      )

      map.addControl new DragControl

      map.on 'dragend', ->
        if $('.search-on-drag').is(":checked")
          $('#loader').show()
          bounds = map.getBounds()
          location = "#{bounds.toBBoxString()}"
          $('#bounds').val(location)
          Rails.fire($('.lodgings-filters').get(0), 'submit')

      map.on 'zoomend', ->
        if $('.search-on-drag').is(":checked")
          bounds = map.getBounds()
          location = "#{bounds.toBBoxString()}"
          $('#bounds').val(location)
          window.bounds_changed = true
          if !window.country_bounds
            $('#loader').show();
            Rails.fire($('.lodgings-filters').get(0), 'submit')
          else
            window.country_bounds = false

      window.bounds_changed = true

  Map.add_markers = (set_bounds = true) ->
    features = $('.lodgings-list-json').map(-> JSON.parse @dataset.features).get()
    markers_layer = map._layers[markers]
    markers_layer.on 'layeradd', (e) ->
      marker = e.layer
      feature = marker.feature
      popupContent = "<a class='popup' href='#{feature.properties.url}'>
                        <img src='#{feature.properties.image}' />#{feature.properties.title}
                      </a>
                      <p>#{feature.properties.description}</p>
                      <p id='feature-price-#{feature.properties.id}' class='feature-price'></p>"
      marker.bindPopup popupContent,
        closeButton: false
        maxWidth: 220
        minWidth: 210
      marker.setIcon(L.divIcon(feature.properties.icon));
    markers_layer.on 'click', (e) ->
      update_popup(e.layer.feature)

    markers_layer.setGeoJSON(features)

    if set_bounds
      set_safe_bounds document.querySelector('.lodgings-list-json'), markers_layer.getBounds()

  set_safe_bounds = (element, bounds_box) ->
    l = element.dataset.bounds
    if ($('.lodgings-filters #country').val() || $('.lodgings-filters #region').val())
      window.country_bounds = true
    else
      window.country_bounds = false

    if l
      latlngs = l.split(',')
      southWest = new L.latLng(latlngs[1], latlngs[0])
      northEast = new L.latLng(latlngs[3], latlngs[2])
      bounds = new L.latLngBounds(southWest, northEast)
      map.fitBounds bounds
      window.bounds_changed = true
    else
      window.bounds_changed = true
      map.fitBounds bounds_box

  Map.init_with = (feature, selector) ->
    L.mapbox.accessToken = 'pk.eyJ1IjoibmljZTJzdGF5IiwiYSI6ImNqcmx5bzN4MzA3NnQ0OW1vb25oNWZpYnQifQ.M-2JMwQg14gQzFxBDivSIg'
    features = $('.lodgings-list-json').map(-> JSON.parse @dataset.feature).get()
    categories = $('.lodgings-list-json').map(-> JSON.parse @dataset.categories).get()

    if window.map && window.map._container.id == selector
      map = window.map
      markers_layer = map._layers[window.markers]
    else
      map = window.map = L.mapbox.map selector, 'mapbox.streets'

      RadiousControl = L.Control.extend(
        options: position: 'topright'
        onAdd: (map) ->
          container = L.DomUtil.create('div', 'my-custom-control bg-white p-2 leaflet-bar')
          radiobuttons = '<h4>Nearby Places</h4>
                        <input type="radio" name="within" value="50km" class="within leaflet-control mt-1" /><label>50km</label><br>
                        <input type="radio" name="within" value="100km" class="within leaflet-control mt-1" checked/><label>100km</label><br>
                        <input type="radio" name="within" value="150km" class="within leaflet-control mt-1" /><label>150km</label>'

          $(container).html(radiobuttons)
          L.DomEvent.addListener container, 'change', (e) ->
            $('.you-may-like-form .within-radius').val($(this).find('.within:checked').val())
            $('#loader').show()
            Rails.fire($('.you-may-like-form').get(0), 'submit')
          container
      )

      CategoryControl = L.Control.extend(
        options: position: 'topright'
        onAdd: (map) ->
          container = L.DomUtil.create('div', 'my-custom-control bg-white p-2 leaflet-bar')
          radiobuttons = '<h4>Place Categories</h4>'
          for category in categories
            radiobuttons += "<input type='checkbox' name='within_category' value='#{category[1]}' class='within_category leaflet-control mt-1' /><label>#{category[0]}</label><br>"

          $(container).html(radiobuttons)
          L.DomEvent.addListener container, 'change', (e) ->
            categories = $.map($(this).find('.within_category:checked'), (c) -> c.value )
            $('.you-may-like-form .within-categories').val(categories)
            $('#loader').show()
            Rails.fire($('.you-may-like-form').get(0), 'submit')
          container
      )

      map.addControl new RadiousControl
      if features.length > 1
        map.addControl new CategoryControl
      window.markers = markers = L.mapbox.featureLayer().addTo(map)._leaflet_id
      markers_layer = map._layers[markers]

    markers_layer.setGeoJSON(features)
    if features.length > 1
      set_safe_bounds document.querySelector('.lodgings-list-json'), markers_layer.getBounds()
    else
      set_safe_bounds document.querySelector('.lodgings-list-json'), markers_layer.getBounds()
      map.setZoom 10

    if map.scrollWheelZoom
      map.scrollWheelZoom.disable()

  Map.highlight_lodgings = ->
    $('.lodgings-list').on 'mouseenter', '.lodging-container', ->
      markers_layer = map._layers[markers]
      lodging_id = $(this).data('lodging-id')
      markers_layer.eachLayer (marker) ->
        if marker.feature.properties.id == lodging_id
          $(".price-icon-#{lodging_id}").addClass 'price-icon-hover'
          update_popup(marker.feature)

    $('.lodgings-list').on 'mouseleave', '.lodging-container', ->
      markers_layer = map._layers[markers]
      lodging_id = $(this).data('lodging-id')
      markers_layer.eachLayer (marker) ->
        if marker.feature.properties.id == lodging_id
          $(".price-icon-#{lodging_id}").removeClass 'price-icon-hover'

  update_popup = (feature) ->
    html = $(".price-review-box-#{feature.properties.id} .review-box").html()
    html += "#{ $(".price-review-box-#{feature.properties.id} .price-text-from").html() || '' } <span class='price'>#{$(".price-review-box-#{feature.properties.id} .price").html()}</span> - #{$(".price-review-box-#{feature.properties.id} .nights-text").html()}"
    $("#feature-price-#{feature.properties.id}").html(html)

).call this
