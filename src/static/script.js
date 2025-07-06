// *** Initialize & retrieve any saved settings from local storage 
let map = L.map('map').setView([0, 0], 2); // init Leaflet map
let issPath = JSON.parse(sessionStorage.getItem('issPath')) || [];
let issMarker = L.marker([0, 0]).addTo(map); // Placeholder marker

// Add OpenStreetMap tile layer
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
  attribution: '&copy; OpenStreetMap contributors'
}).addTo(map);

// Draw any previously saved path
if (issPath.length > 0 && issPath.every(coord => Array.isArray(coord) && coord.length === 2)) {
  L.polyline(issPath, { color: 'red' }).addTo(map);
  map.fitBounds(L.latLngBounds(issPath), { padding: [50, 50], maxZoom: 2 });
}

async function fetchISSLocation() {
        console.log("Fetching ISS location...");
        try {
            const response = await fetch('/iss-location'); // Make sure it's /iss-location, NOT /
            const data = await response.json(); // Parse JSON
            console.log("✅ Data received:", data);
            
            if (!data.latitude || !data.longitude) {
                console.warn("⚠️ No valid coordinates in data:", data);
            }

            const newCoord = [data.latitude, data.longitude];
            issPath.push(newCoord);
            issPath = issPath.slice(-20); // Keep last 20
            sessionStorage.setItem('issPath', JSON.stringify(issPath));

            // Draw path on the map
            let polyline = L.polyline(issPath, { color: 'red' }).addTo(map);
            issMarker.setLatLng(newCoord);

            // Display data from API call
            document.getElementById('latitude').textContent = data.latitude;
            document.getElementById('longitude').textContent = data.longitude;
            document.getElementById('altitude').textContent = `${data.altitude_mi} mi (${data.altitude_km} km)`;
            document.getElementById('velocity').textContent = `${data.velocity_mph} mph (${data.velocity_kmh} km/h)`;
            document.getElementById('visibility').textContent = data.visibility; // Show daylight/night status
            
            if (issPath.length > 0) {
                let bounds = L.latLngBounds(issPath);
                map.fitBounds(bounds, { padding: [50, 50], maxZoom: 2 });
            }

        } catch (error) {
            console.error('Error fetching ISS location:', error);
        }
    }

    // inital fetch
    fetchISSLocation();