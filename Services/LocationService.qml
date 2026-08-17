import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
pragma Singleton

Singleton {
    id: root

    property string locationFile: (Config.cacheDir + "location.json")
    property int weatherUpdateFrequency: 30 * 60
    property bool isFetchingWeather: false
    readonly property bool locationConfigured: Config.data.weather.locationName !== ""
    readonly property alias data: adapter
    // Stable UI properties - only updated when location is successfully geocoded
    property bool coordinatesReady: false
    property string stableLatitude: ""
    property string stableLongitude: ""
    property string stableName: ""
    // Formatted coordinates for UI display
    readonly property string displayCoordinates: {
        if (!root.coordinatesReady || root.stableLatitude === "" || root.stableLongitude === "")
            return "";

        const lat = parseFloat(root.stableLatitude).toFixed(4);
        const lon = parseFloat(root.stableLongitude).toFixed(4);
        return `${lat}, ${lon}`;
    }

    function init() {
        Logger.i("Location", "Service started");
    }

    function resetWeather() {
        Logger.i("Location", "Resetting location and weather data");
        root.coordinatesReady = false;
        root.stableLatitude = "";
        root.stableLongitude = "";
        root.stableName = "";
        adapter.latitude = "";
        adapter.longitude = "";
        adapter.name = "";
        adapter.weatherLastFetch = 0;
        adapter.weather = null;
        isFetchingWeather = false;
        update();
    }

    // Main update function - geocodes location if needed, then fetches weather if enabled
    function update() {
        updateLocation();
        if (Config.data.weather.updateWeather)
            updateWeatherData();

    }

    function updateLocation() {
        const locationChanged = adapter.name !== Config.data.weather.locationName;
        const needsGeocoding = (adapter.latitude === "") || (adapter.longitude === "") || locationChanged;
        if (!needsGeocoding)
            return ;

        if (isFetchingWeather)
            return ;

        isFetchingWeather = true;
        if (locationChanged) {
            root.coordinatesReady = false;
            Logger.d("Location", "Location changed from", adapter.name, "to", Config.data.weather.locationName);
        }
        geocodeLocation(Config.data.weather.locationName, function(latitude, longitude, name, country) {
            adapter.name = Config.data.weather.locationName;
            adapter.latitude = latitude.toString();
            adapter.longitude = longitude.toString();
            root.stableLatitude = adapter.latitude;
            root.stableLongitude = adapter.longitude;
            root.stableName = `${name}, ${country}`;
            root.coordinatesReady = true;
            isFetchingWeather = false;
            Logger.i("Location", `Geocoded ${Config.data.weather.locationName}: ${root.stableLatitude}, ${root.stableLongitude}`);
            if (locationChanged) {
                adapter.weatherLastFetch = 0;
                updateWeatherData();
            }
        }, errorCallback);
    }

    // Fetch weather data if enabled and coordinates are available
    function updateWeatherData() {
        if (!Config.data.weather.updateWeather)
            return ;

        if (isFetchingWeather)
            return ;

        if (adapter.latitude === "" || adapter.longitude === "") {
            Logger.w("Location", "Cannot fetch weather without coordinates");
            return ;
        }
        const needsWeatherUpdate = (adapter.weatherLastFetch === "") || (adapter.weather === null) || (Time.timestamp >= adapter.weatherLastFetch + weatherUpdateFrequency);
        if (needsWeatherUpdate) {
            isFetchingWeather = true;
            fetchWeatherData(adapter.latitude, adapter.longitude, errorCallback);
        }
    }

    // Query geocoding API to convert location name to coordinates
    function geocodeLocation(locationName, callback, errorCallback) {
        if (locationName === "") {
            isFetchingWeather = false;
            return ;
        }
        Logger.d("Location", "Geocoding location name");
        var geoUrl = "https://api.noctalia.dev/geocode?city=" + encodeURIComponent(locationName);
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var geoData = JSON.parse(xhr.responseText);
                        if (geoData.lat != null)
                            callback(geoData.lat, geoData.lng, geoData.name, geoData.country);
                        else
                            errorCallback("Location", "could not resolve location name");
                    } catch (e) {
                        errorCallback("Location", "Failed to parse geocoding data: " + e);
                    }
                } else {
                    errorCallback("Location", `Geocoding error: ${xhr.status} ${xhr.responseText}`);
                }
            }
        };
        xhr.open("GET", geoUrl);
        xhr.send();
    }

    // Fetch weather data from Open-Meteo API
    function fetchWeatherData(latitude, longitude, errorCallback) {
        Logger.d("Location", "Fetching weather from api.open-meteo.com");
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude + "&current_weather=true&current=relativehumidity_2m,surface_pressure,is_day&daily=temperature_2m_max,temperature_2m_min,weathercode,sunset,sunrise&timezone=auto";
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var weatherData = JSON.parse(xhr.responseText);
                        // Save core data
                        data.weather = weatherData;
                        data.weatherLastFetch = Time.timestamp;
                        // Update stable display values only when complete and successful
                        root.stableLatitude = data.latitude = weatherData.latitude.toString();
                        root.stableLongitude = data.longitude = weatherData.longitude.toString();
                        root.coordinatesReady = true;
                        isFetchingWeather = false;
                        Logger.d("Location", "Cached weather to disk - stable coordinates updated");
                    } catch (e) {
                        errorCallback("Location", "Failed to parse weather data");
                    }
                } else {
                    errorCallback("Location", `Weather error: ${xhr.status} ${xhr.responseText}`);
                }
            }
        };
        xhr.open("GET", url);
        xhr.send();
    }

    function parseWMO(wmo, isDay) {
        var wmoIndex = JSON.parse(wmoIndexFileView.text());
        if (isDay)
            return wmoIndex[wmo]["day"];
        else
            return wmoIndex[wmo]["night"];
    }

    function errorCallback(module, message) {
        Logger.w(module, message);
        isFetchingWeather = false;
    }

    FileView {
        id: locationFileView

        path: locationFile
        printErrors: false
        onAdapterUpdated: saveTimer.start()
        onLoaded: {
            Logger.d("Location", "Loaded cached data");
            if (adapter.latitude !== "" && adapter.longitude !== "" && adapter.weatherLastFetch > 0) {
                root.stableLatitude = adapter.latitude;
                root.stableLongitude = adapter.longitude;
                root.stableName = adapter.name;
                root.coordinatesReady = true;
                Logger.i("Location", "Coordinates ready");
            }
            update();
        }
        onLoadFailed: function(error) {
            update();
        }

        JsonAdapter {
            id: adapter

            property string latitude: ""
            property string longitude: ""
            property string name: ""
            property int weatherLastFetch: 0
            property var weather: null
        }

    }

    FileView {
        id: wmoIndexFileView

        path: Quickshell.shellDir + "/Assets/wmo.json"
        blockLoading: true
    }

    // Update timer runs when weather is enabled or location-based scheduling is active
    Timer {
        id: updateTimer

        interval: 20 * 1000
        running: Config.data.weather.updateWeather
        repeat: true
        onTriggered: {
            update();
        }
    }

    Timer {
        id: saveTimer

        running: false
        interval: 1000
        onTriggered: locationFileView.writeAdapter()
    }

}
