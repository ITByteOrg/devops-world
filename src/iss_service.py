import logging
import os

import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
ISS_API_URL = os.getenv("ISS_API_URL", "https://api.wheretheiss.at/v1/satellites/25544")

# Configure logging to write to a file (`logs/iss.log`)
LOG_DIR = "logs"
os.makedirs(LOG_DIR, exist_ok=True)  # Ensure log directory exists
logging.basicConfig(
    filename=os.path.join(LOG_DIR, "iss.log"),
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)


def get_iss_location():
    # Fetch the current location of the ISS with logging and error handling.
    try:
        response = requests.get(ISS_API_URL, timeout=5)
        response.raise_for_status()
        data = response.json()
        latitude = data.get("latitude")
        longitude = data.get("longitude")
        altitude = data.get("altitude")
        velocity = data.get("velocity")
        visibility = data.get("visibility")

        if latitude is None or longitude is None:
            raise KeyError("Missing keys in response JSON")

        logging.info(
            f"ISS Location: {latitude}, {longitude}, {altitude}, {velocity}, {visibility}"
        )  # Log coordinates
        return data

    except requests.exceptions.Timeout:
        logging.error("API request timed out.")
        return {"error": "Request timed out"}

    except requests.exceptions.RequestException as e:
        logging.error(f"Failed to fetch ISS data: {e}")
        return {"error": "Failed to fetch ISS data", "details": str(e)}
