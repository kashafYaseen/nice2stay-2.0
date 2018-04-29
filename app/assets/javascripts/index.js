var map;

window.addMarkers = function addMarkers() {
  var element = document.querySelector("#lodgings-list");
  var lodgings = window.transactions = JSON.parse(element.dataset.lodgings);

  map.removeMarkers();

  lodgings.forEach(function(lodging) {
    if (lodging.latitude && lodging.longitude) {
      var marker = map.addMarker({
        lat: lodging.latitude,
        lng: lodging.longitude,
        title: lodging.address,
        infoWindow: {
          content: `<p><a href='/lodgings/${lodging.id}'>${lodging.address}</a></p>`
        }
      });
    }
  });

  setSafeBounds(element);
}

function setSafeBounds(element) {
  var l = element.dataset.l;
  if (l) {
    var latlngs   = l.split(',');
    var southWest = new google.maps.LatLng(latlngs[0], latlngs[1]);
    var northEast = new google.maps.LatLng(latlngs[2], latlngs[3]);
    var bounds    = new google.maps.LatLngBounds(southWest, northEast);
    map.fitBounds(bounds, 0);

  } else {
    map.fitZoom();
  }
}

document.addEventListener("turbolinks:load", function() {
  map = window.map = new GMaps({
    div: '#map',
    lat: 38.5816,
    lng: -121.4944
  });

  addMarkers();

  map.addListener("dragend", function() {
    var bounds = map.getBounds();
    var location = bounds.getSouthWest().toUrlValue() + "," + bounds.getNorthEast().toUrlValue();

    Turbolinks.visit(`/lodgings?l=${location}`);
  });


  map.addListener("zoom_changed", function() {
    var bounds = map.getBounds();
    var location = bounds.getSouthWest().toUrlValue() + "," + bounds.getNorthEast().toUrlValue();

    Turbolinks.visit(`/lodgings?l=${location}`);
  });
});
