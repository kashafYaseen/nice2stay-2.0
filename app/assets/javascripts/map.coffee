(->
  window.Map or (window.Map = {})

  Map.init = ->
    if $('#map').length
      map = window.map = new GMaps(
        div: '#map'
        lat: 38.5816
        lng: -121.4944)
      Map.add_markers()
      map.addListener 'dragend', ->
        bounds = map.getBounds()
        location = bounds.getSouthWest().toUrlValue() + ',' + bounds.getNorthEast().toUrlValue()
        $('#bounds').val(location)
        Rails.fire($('.lodgings-filters').get(0), 'submit')

  Map.add_markers = ->
    element = document.querySelector('#lodgings-list')
    lodgings = window.transactions = JSON.parse(element.dataset.lodgings)
    map.removeMarkers()
    lodgings.forEach (lodging) ->
      if lodging.latitude and lodging.longitude
        marker = map.addMarker(
          lat: lodging.latitude
          lng: lodging.longitude
          title: lodging.address
          infoWindow: content: "<p><a href='/lodgings/#{lodging.id}'>#{lodging.address}</a></p>")
    set_safe_bounds element

  set_safe_bounds = (element) ->
    l = element.dataset.l
    if l
      latlngs = l.split(',')
      southWest = new (google.maps.LatLng)(latlngs[0], latlngs[1])
      northEast = new (google.maps.LatLng)(latlngs[2], latlngs[3])
      bounds = new (google.maps.LatLngBounds)(southWest, northEast)
      map.fitBounds bounds, 0
    else
      map.fitZoom()

).call this
