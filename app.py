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
@app.route("/")
def home():
    return render_template("index.html")

@app.route("/iss-location")
def iss_location():
    data = get_iss_location()
    return jsonify(data)

if __name__ == "__main__":
    app.run(debug=True)

