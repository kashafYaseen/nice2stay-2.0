(->
  window.Map or (window.Map = {})

  Map.init = ->
    if $('#map').length
      L.mapbox.accessToken = 'pk.eyJ1IjoibmljZTJzdGF5IiwiYSI6ImNqcmx5bzN4MzA3NnQ0OW1vb25oNWZpYnQifQ.M-2JMwQg14gQzFxBDivSIg'
      map = window.map = L.mapbox.map 'map', 'mapbox.streets'
      map.setView [38.5816, -121.4944], 12

      bounds_changed = window.bounds_changed = false
      Map.add_markers()
      # Map.highlight_lodgings()

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
    lodgings = $('.lodgings-list-json').map(-> JSON.parse @dataset.lodgings).get()
    ids = $('.lodgings-list-json').map(-> JSON.parse @dataset.ids).get()
    jeo_json = $('.lodgings-list-json').map(-> JSON.parse @dataset.markers).get()
    markers_layer = L.mapbox.featureLayer().addTo(map)

    markers_layer.on 'layeradd', (e) ->
      marker = e.layer
      feature = marker.feature
      popupContent = "<a target='_blank' class='popup' href='#{feature.properties.url}'>
                        <img src='#{feature.properties.image}' />#{feature.properties.title}
                      </a>"
      marker.bindPopup popupContent,
        closeButton: true
        minWidth: 320

    markers_layer.setGeoJSON(jeo_json)

    # remove_marker_list = []
    # for marker in map.markers
    #   if marker && ids.includes(marker.id)
    #     continue
    #   remove_marker_list.push marker
    # map.removeMarkers(remove_marker_list)

    # for lodging in lodgings
    #   if lodging.latitude and lodging.longitude
    #     marker = L.marker([lodging.longitude, lodging.latitude]).addTo(map)
    #     marker.setPopupContent("<p><a href='accommodations/#{lodging.slug}'>#{lodging.name}</a></p>")

    #     marker = map.addMarker(
    #       id: lodging.id
    #       lat: lodging.latitude
    #       lng: lodging.longitude
    #       title: lodging.address
    #       infoWindow: content: "<p><a href='accommodations/#{lodging.slug}'>#{lodging.name}</a></p>")
    if set_bounds
      #map.fitBounds markers_layer.getBounds()
      set_safe_bounds document.querySelector('.lodgings-list-json'), markers_layer.getBounds()

  set_safe_bounds = (element, bounds_box) ->
    l = element.dataset.bounds
    if l
      latlngs = l.split(',')
      southWest = new L.latLng(latlngs[1], latlngs[0])
      northEast = new L.latLng(latlngs[3], latlngs[2])
      bounds = new L.latLngBounds(southWest, northEast)
      zoom = map.getZoom()
      window.bounds_changed = true
      map.fitBounds bounds, 0
      window.bounds_changed = true
      map.setZoom zoom
    else
      window.bounds_changed = true
      #map.fitZoom()
      map.fitBounds bounds_box

  Map.init_with = (lat, lng, selector) ->
    if $(selector).length > 0
      map = window.map = new GMaps(
        div: selector
        lat: lat
        lng: lng
      )

      Map.add_markers(false)
      map.setZoom 7

  Map.highlight_lodgings = ->
    $('.lodgings-list').on 'mouseenter', '.lodging-container', ->
        markers = map.markers
        for marker in markers
          if marker.id == $(this).data('lodging-id')
            marker.setAnimation 1

    $('.lodgings-list').on 'mouseleave', '.lodging-container', ->
        markers = map.markers
        for marker in markers
          if marker.id == $(this).data('lodging-id')
            marker.setAnimation(null)

).call this
