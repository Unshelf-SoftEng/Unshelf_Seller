// web/assets/js/maps.js
function initMap(apiKey) {
  const mapOptions = {
    center: { lat: 0.0, lng: 0.0 },
    zoom: 15,
  };
  const map = new google.maps.Map(document.getElementById("map"), mapOptions);

  google.maps.event.addListener(map, "click", function (event) {
    window.flutter_inappwebview.callHandler(
      "onMapClick",
      event.latLng.lat(),
      event.latLng.lng()
    );
  });

  return map;
}

window.initMap = initMap;
