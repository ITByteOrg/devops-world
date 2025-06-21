# DevOps World

Welcome to **DevOps World**, a simple Python application designed to be tested and deployed through a complete **DevOps workflow**. This repository focuses on the application, including setup, dependencies, and basic usage.

---

## Overview
This repository contains a simple Python application slightly more interesting than "Hello World". In this journey, I'm focusing on the DevOps stack. This repo is only for the application, as separate repos were set up for infrastructure, security, and monitoring configurations. As the project progresses, the repository links below will expand with details on cloud deployment, CI/CD pipelines, security scanning, and monitoring practices.

- **DevOps Infrastructure:** [`devops-infra`](https://github.com/ITByteEnthusiast/devops-infra/blob/main/README.md)  
- **DevOps Security:** [`devops-security`](https://github.com/ITByteEnthusiast/devops-security/blob/main/README.md)  
- **DevOps Monitoring:** [`devops-monitoring`](https://github.com/ITByteEnthusiast/devops-monitoring/blob/main/README.md)  

---

## Getting Started

### Prerequisites
You’ll want a dependable tool for editing and managing your files — modern IDEs make that process much more efficient. While it's technically possible to build everything using something like Notepad, modern IDEs offer far more—integrated debugging, IntelliSense, and a smoother development experience overall. There are excellent open-source options, so explore a few and choose one that suits your workflow.

Here's what I used
- Visual Studio Code (or any IDE that supports the latest version of Python)
- Python (latest version recommended)
- pip (for dependency management)  
- Git (to clone the repository)
- Obsidian - started using this for markdown editing, but decided VS Code is enough for my needs and fits my workflow better.    

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
python src/app.py
```
> If `python` doesn't work, try `python3 app.py`.

In your browser, navigate to **http://127.0.0.1:5000/** to see the running app.

To stop the server, press `Ctrl+C` in the terminal.

_Tip: You can use the integrated terminal in Visual Studio Code for all commands above._

---
## Repository Structure

This section provides a high-level view of the application directory structure. As the CI/CD stack takes shape, I anticipate breaking out iss_service.py into a dedicated microservice for improved modularity. Initially, src/ and templates/ were placed at the top level. But as the project matured, I moved templates/ under src/ to better align with Flask’s organizational conventions and keep app-specific logic and views together. (And yes—templates/index.html will be removed soon... possibly before anyone reads this.)

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
│── Dockerfile          # docker build
```
---
## Debug Utilities
Manual GitHub Actions for branch logic + context inspection  
→ [See debug workflows](.github/workflows/README.md)

---
## Next Step

After setting up the repositories and scaffolding the application, I focused on establishing a strong CI/CD framework. Although the order suited this exploratory build, I’d reverse it in a production context—starting with a robust CI/CD pipeline. Laying that foundation early promotes good engineering hygiene—enforcing automated scans, pull request gates, and approval workflows before anything lands in main. As I continue to build out the project, I will likely reorder these pages, but for now, the journey continues. My next stop in the journey was devops-infra for the Terraform setup. 

---
## License
This project is licensed under **Creative Commons Attribution 4.0 International License (CC-BY-4.0).**  
🔗 **Full license details:** [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/)

## Contributing

While this project is publicly available under an open license, contributions are currently not being accepted.

You're welcome to use, fork, or adapt the scripts for your infrastructure work. If you find them helpful, a star or mention is always appreciated.

## Maintainer
Developed and maintained by ITByteEnthusiast.
