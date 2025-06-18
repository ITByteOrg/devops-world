import os
import logging
from flask import Flask, render_template, jsonify
from dotenv import load_dotenv
from iss_service import get_iss_location  

# Load environment variables - defaults to dev
ENV = os.getenv("FLASK_ENV", "dev")
load_dotenv(f".env.{ENV}")

# Initialize Flask web app instance
app = Flask(__name__)

# Set up logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Routes
@app.route('/')
def home():
    return render_template("index.html")  # Serve HTML page

@app.route('/iss-location')
def iss_location():
    try:
        iss_data = get_iss_location()
     
        # Ensure latitude & longitude exist before using them
        if not iss_data or "latitude" not in iss_data or "longitude" not in iss_data:
            logging.error("ISS data missing latitude/longitude")
            return jsonify({"error": "Failed to retrieve ISS data"}), 500
            
        # Convert units
        altitude_miles = round(iss_data.get("altitude") * 0.621371,2)  # Convert km to miles
        velocity_mph = round(iss_data.get("velocity") * 0.621371,2)  # Convert km/h to mph

        return jsonify({
            "latitude": iss_data["latitude"],
            "longitude": iss_data["longitude"],
            "altitude_km": round(iss_data.get("altitude"),2),
            "altitude_mi": altitude_miles,
            "velocity_kmh": round(iss_data.get("velocity"),2),
            "velocity_mph": velocity_mph,
            "visibility": iss_data.get("visibility")
        })

    except Exception as e:
        logging.exception("Error fetching ISS data")
        return jsonify({"error": "Internal server error"}), 500        

if __name__ == '__main__':
    app.run(debug=True)