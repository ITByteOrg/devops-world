### **DevOps World – README**  

Welcome to **DevOps World**, a simple Python application designed to be tested and deployed through a complete **DevOps workflow**. This repository focuses on the application itself, including setup, dependencies, and basic usage.

---

## **Overview**  
This repository contains a basic Python application that will be integrated into a larger DevOps stack, but it **only includes the application itself**—not infrastructure, security, or monitoring configurations. Those components are managed separately in their respective repositories:

- **DevOps Infrastructure:** [`devops-infra`](https://github.com/ITByteEnthusiast/devops-infra/blob/main/README.md)  
- **DevOps Security:** [`devops-security`](https://github.com/ITByteEnthusiast/devops-security/blob/main/README.md)  
- **DevOps Monitoring:** [`devops-monitoring`](https://github.com/ITByteEnthusiast/devops-monitoring/blob/main/README.md)  

For details on cloud deployment, CI/CD pipelines, security scanning, and monitoring setup, refer to the above repositories.

---

## **Getting Started**  

### **Prerequisites**  
Ensure you have the following installed:  
- IDE to work with latest version of Python (I used Anaconda but feel free to use any IDE)
- pip (for dependency management)  
- Git (to clone the repository)  
- Flask for dynamic web pages

### **Installation**  

Clone the repository and move into the project directory

```bash
git clone https://github.com/yourusername/devops-world.git
cd devops-world
```

### **Install Python (If Not Installed)**

Before proceeding, **ensure Python is installed**.
### **Windows Users:**

1. Download Python from the official site: Python.org
    
2. Run the installer and **check the box to add Python to PATH**.
    
3. Verify the installation with:
    
    powershell
    
    ```
    python --version
    ```
    
### **Mac/Linux Users (Optional, Not Tested)**

Install Python via your package manager:

bash

```
brew install python  # macOS
sudo apt install python3  # Debian/Ubuntu
```

Check the installation with:

bash

```
python3 --version
```
## **Set Up a Virtual Environment**

Create and activate a virtual environment to isolate dependencies:

### **Windows Users:**

powershell

```
python -m venv venv
venv\Scripts\activate
```

### **Mac/Linux Users (Optional, Not Tested)**

bash

```
python -m venv venv
source venv/bin/activate
```

✅ _You'll know it's activated when you see_ `(venv)` _in your terminal._

## **Install Dependencies**

bash

```
pip install -r requirements.txt
```

## **Run the Application**

bash

```
python app.py
```

Now, open your browser and navigate to **http://127.0.0.1:5000/** to see the running app.

---

## **Repository Structure**  
```
devops-world/
│── app.py            # Main application script
│── iss_service.py    # API call to location of ISS
│── requirements.txt  # Dependencies
│── README.md         # Project documentation
│── .gitignore        # Git ignore rules
│── /templates        # html pages
```

---

## **License**  
This project is licensed under **Creative Commons Attribution 4.0 International License (CC-BY-4.0).**  
🔗 **Full license details:** [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/)

---

## **Contributions**  
At this time, this repository is not open for external contributions. However, you are welcome to explore the content, learn from it, and use it within the terms of the **CC-BY-4.0** license. Thank you for your interest!

---

## **Contact and Contributions**  
For questions or suggestions, reach out via **GitHub Issues**.

---
