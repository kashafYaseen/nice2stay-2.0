(->
  window.Map or (window.Map = {})

  Map.init = ->
    if $('#map').length
      L.mapbox.accessToken = 'pk.eyJ1IjoibmljZTJzdGF5IiwiYSI6ImNqcmx5bzN4MzA3NnQ0OW1vb25oNWZpYnQifQ.M-2JMwQg14gQzFxBDivSIg'
      map = window.map = L.mapbox.map 'map', 'mapbox.streets'
      map.setView [38.5816, -121.4944], 12
      window.markers = markers = L.mapbox.featureLayer().addTo(map)._leaflet_id
      bounds_changed = window.bounds_changed = false
      Map.add_markers()
      Map.highlight_lodgings()

      map.on 'dragend', ->
        $('#loader').show()
        bounds = map.getBounds()
        location = "#{bounds.toBBoxString()}"
        $('#bounds').val(location)
        Rails.fire($('.lodgings-filters').get(0), 'submit')

      map.on 'zoomend', ->
        bounds = map.getBounds()
        if window.bounds_changed
          window.bounds_changed = false
        else
          $('#loader').show();
          location = "#{bounds.toBBoxString()}"
          $('#bounds').val(location)
          window.bounds_changed = true
          Rails.fire($('.lodgings-filters').get(0), 'submit')
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
        maxWidth: 200
        minWidth: 200
    markers_layer.on 'click', (e) ->
      update_popup(e.layer.feature)

    markers_layer.setGeoJSON(features)

    if set_bounds
      set_safe_bounds document.querySelector('.lodgings-list-json'), markers_layer.getBounds()

  set_safe_bounds = (element, bounds_box) ->
    l = element.dataset.bounds
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
    map = window.map = L.mapbox.map selector, 'mapbox.streets'
    marker = L.mapbox.featureLayer().setGeoJSON(features).addTo(map);
    set_safe_bounds document.querySelector('.lodgings-list-json'), marker.getBounds()
    map.setZoom 9

  Map.highlight_lodgings = ->
    $('.lodgings-list').on 'mouseenter', '.lodging-container', ->
      markers_layer = map._layers[markers]
      lodging_id = $(this).data('lodging-id')
      markers_layer.eachLayer (marker) ->
        if marker.feature.properties.id == lodging_id
          marker.openPopup()
          update_popup(marker.feature)

    $('.lodgings-list').on 'mouseleave', '.lodging-container', ->
      markers_layer = map._layers[markers]
      lodging_id = $(this).data('lodging-id')
      markers_layer.eachLayer (marker) ->
        if marker.feature.properties.id == lodging_id
          marker.closePopup()

  update_popup = (feature) ->
    $("#feature-price-#{feature.properties.id}").html($(".price-review-box-#{feature.properties.id}").html())

).call this
