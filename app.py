import os
from flask import Flask, render_template, jsonify
from dotenv import load_dotenv
from iss_service import get_iss_location  # Separate logic from app.py

# Load environment variables - defaults to dev
ENV = os.getenv("FLASK_ENV", "dev")
load_dotenv(f".env.{ENV}")

# Initialize Flask
app = Flask(__name__)

# Routes
@app.route('/')
def home():
    return render_template("index.html")  # Serve HTML page

@app.route('/iss-location')
def iss_location():
    iss_data = get_iss_location()
 
    # Ensure latitude & longitude exist before using them
    latitude = iss_data.get("latitude")
    longitude = iss_data.get("longitude")

    # Convert units
    altitude_miles = iss_data.get("altitude") * 0.621371  # Convert km to miles
    velocity_mph = iss_data.get("velocity") * 0.621371  # Convert km/h to mph
    
    return jsonify({
        "latitude": latitude,
        "longitude": longitude,
        "altitude_km": round(iss_data.get("altitude"),2),
        "altitude_mi": round(altitude_miles, 2),  # Rounded for cleaner display
        "velocity_kmh": round(iss_data.get("velocity"),2),
        "velocity_mph": round(velocity_mph, 2),  # Rounded for cleaner display 
        "visibility": iss_data.get("visibility")
    })

if __name__ == '__main__':
    app.run(debug=True)