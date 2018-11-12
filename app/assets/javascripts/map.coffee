(->
  window.Map or (window.Map = {})

  Map.init = ->
    if $('#map').length
      map = window.map = new GMaps(
        div: '#map'
        lat: 38.5816
        lng: -121.4944)

      bounds_changed = window.bounds_changed = false
      Map.add_markers()
      Map.highlight_lodgings()

      map.addListener 'dragend', ->
        $('#loader').show()
        bounds = map.getBounds()
        location = "#{bounds.getSouthWest().toUrlValue()}, #{bounds.getNorthEast().toUrlValue()}"
        $('#bounds').val(location)
        Rails.fire($('.lodgings-filters').get(0), 'submit')

      map.addListener 'zoom_changed', ->
        bounds = map.getBounds()
        if window.bounds_changed
          window.bounds_changed = false
        else
          $('#loader').show();
          location = "#{bounds.getSouthWest().toUrlValue()}, #{bounds.getNorthEast().toUrlValue()}"
          $('#bounds').val(location)
          window.bounds_changed = true
          Rails.fire($('.lodgings-filters').get(0), 'submit')
      window.bounds_changed = true

  Map.add_markers = (set_bounds = true) ->
    lodgings = $('.lodgings-list-json').map(-> JSON.parse @dataset.lodgings).get()
    ids = $('.lodgings-list-json').map(-> JSON.parse @dataset.ids).get()
    remove_marker_list = []
    for marker in map.markers
      if marker && ids.includes(marker.id)
        continue
      remove_marker_list.push marker
    map.removeMarkers(remove_marker_list)

    for lodging in lodgings
      if lodging.latitude and lodging.longitude
        marker = map.addMarker(
          id: lodging.id
          lat: lodging.latitude
          lng: lodging.longitude
          title: lodging.address
          infoWindow: content: "<p><a href='accommodations/#{lodging.slug}'>#{lodging.name}</a></p>")
    if set_bounds
      set_safe_bounds document.querySelector('.lodgings-list-json')

  set_safe_bounds = (element) ->
    l = element.dataset.bounds
    if l
      latlngs = l.split(',')
      southWest = new (google.maps.LatLng)(latlngs[0], latlngs[1])
      northEast = new (google.maps.LatLng)(latlngs[2], latlngs[3])
      bounds = new (google.maps.LatLngBounds)(southWest, northEast)
      zoom = map.getZoom()
      window.bounds_changed = true
      map.fitBounds bounds, 0
      window.bounds_changed = true
      map.setZoom zoom
    else
      window.bounds_changed = true
      map.fitZoom()

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
