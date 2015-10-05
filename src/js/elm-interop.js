"use strict";

var elmApp = Elm.fullscreen(Elm.Main, {selectMarker: null});

// @todo: Remove this hack, that makes sure that the map will appear on first
// load, as the subscribe to port is triggered only on the first change of
// model, and not when it is initialized.
elmApp.ports.selectMarker.send(null);

// Maintain the map and marker state.
var mapEl = undefined;
var markersEl = {};

var defaultIcon = L.icon({
  iconRetinaUrl: 'default@2x.png',
  iconSize: [35, 46]
});

var selectedIcon = L.icon({
  iconRetinaUrl: 'selected@2x.png',
  iconSize: [35, 46]
});

elmApp.ports.mapManager.subscribe(function(model) {
  console.log(model);
  // We use timeout, to let virtual-dom add the div we need to bind to.
  setTimeout(function () {
    if (!model.showMap && !!mapEl) {
      mapEl.remove();
      mapEl = undefined;
      markersEl = {};
      return;
    }

    mapEl = mapEl || addMap();

    model.markers.forEach(function(marker) {
      if (!markersEl[marker.id]) {
        markersEl[marker.id] = L.marker([marker.lat, marker.lng]).addTo(mapEl);
        selectMarker(markersEl[marker.id], marker.id);
      }
      else {
        markersEl[marker.id].setLatLng([marker.lat, marker.lng]);
      }

      // Set the marker's icon.
      markersEl[marker.id].setIcon(!!model.selectedMarker && model.selectedMarker === marker.id ? selectedIcon : defaultIcon);
    });
  }, 50);

});

/**
 * Send marker click event to Elm.
 */
function selectMarker(markerEl, id) {
  markerEl.on('click', function(e) {
    elmApp.ports.selectMarker.send(id);
  });
}

/**
 * Initialize a Leaflet map.
 */
function addMap() {
  // Leaflet
  var mapEl = L.map('map').setView([51.505, -0.09], 10);

  L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6IjZjNmRjNzk3ZmE2MTcwOTEwMGY0MzU3YjUzOWFmNWZhIn0.Y8bhBaUMqFiPrDRW9hieoQ', {
    maxZoom: 10,
    id: 'mapbox.streets'
  }).addTo(mapEl);

  return mapEl;
}
