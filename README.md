# DevOps World

Welcome to **DevOps World**, a simple Python application designed to be tested and deployed through a complete **DevOps workflow**. This repository focuses on the application, including setup, dependencies, and basic usage.

---

## Overview
This repository contains a simple Python application that will be integrated into a larger DevOps stack, but it **only includes the application itself**—not infrastructure, security, or monitoring configurations. Those components are managed separately in their respective repositories:

- **DevOps Infrastructure:** [`devops-infra`](https://github.com/ITByteEnthusiast/devops-infra/blob/main/README.md)  
- **DevOps Security:** [`devops-security`](https://github.com/ITByteEnthusiast/devops-security/blob/main/README.md)  
- **DevOps Monitoring:** [`devops-monitoring`](https://github.com/ITByteEnthusiast/devops-monitoring/blob/main/README.md)  

For details on cloud deployment, CI/CD pipelines, security scanning, and monitoring setup, refer to the above repositories.

---

## Getting Started

### Prerequisites
Ensure you have the following installed:  
- Visual Studio Code (or any IDE that supports the latest version of Python)
- Python (latest version recommended)
- pip (for dependency management)  
- Git (to clone the repository)  

### Installation

#### 1. Clone repo

Clone the repository and move into the project directory

```bash
git clone https://github.com/yourusername/devops-world.git
cd devops-world
```

#### 2. Install Python (If Not Installed)

- **Windows:**
  1. Download Python from [python.org](https://www.python.org/).
  2. Run the installer and **check the box to add Python to PATH**.
  3. Verify installation:
     ```powershell
     python --version
     ```
    
- **Mac/Linux:**
  1. Install Python via your package manager:
     ```bash
     brew install python  # macOS
     sudo apt install python3  # Debian/Ubuntu
     ```
  2. Verify installation:
     ```bash
     python3 --version
     ```

#### 3. Set Up a Virtual Environment

Create and activate a virtual environment to isolate dependencies:

- **Windows:**
  ```powershell
  python -m venv venv
  .\venv\Scripts\activate
  ```
> If `python` doesn't work, try `py -m venv venv`.

- **Mac/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

■ _You'll know it's activated when you see_ `(venv)` _in your terminal._

#### 4. Install Dependencies

Install all required Python packages using:

```bash
pip install -r requirements.txt
```

> **Note:** All required Python packages (including Flask) will be installed automatically from `requirements.txt`. You do not need to install them individually.

---
## Run the Application

Start the Flask app with:

```bash
python app.py
```
> If `python` doesn't work, try `python3 app.py`.

Now, open your browser and navigate to **http://127.0.0.1:5000/** to see the running app.

To stop the server, press `Ctrl+C` in the terminal.

_Tip: You can use the integrated terminal in Visual Studio Code for all commands above._

---
## Repository Structure
```
devops-world/
│── .github/
│   └── workflows/
│       └── security_scan.yml  # GitHub Actions workflow for security scanning
│       └── docker-build.yml   
│       └── ci-dev.yml
│── requirements.txt    # Python dependencies
│── README.md           # Project documentation
│── .gitignore          # Git ignore rules
│── .trufflehogignore   # Trufflehog ignore rules
│── src/                # Application source code
│   ├── app.py          # Main application script
│   └── iss_service.py  # API call to location of ISS
│── config/             # Configuration files (YAML, etc.)
│── templates/          # HTML templates for Flask
```

---
## Next Step

Now that your application repository is set up, it's time to review the overall security setup. Head over to the [README](https://github.com/ITByteEnthusiast/devops-security/blob/main/README.md) in the **devops-security** repository for an overview of key security practices used in this project. 

---
## License
This project is licensed under **Creative Commons Attribution 4.0 International License (CC-BY-4.0).**  
🔗 **Full license details:** [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/)

---
## Contributions
At this time, this repository is not open for external contributions. However, you are welcome to explore the content, learn from it, and use it within the terms of the **CC-BY-4.0** license. Thank you for your interest!

---
## Contact 
For questions or suggestions, reach out via [GitHub Issues](https://github.com/ITByteEnthusiast/devops-world/issues).


