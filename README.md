🧺 Laundry Management App + AI Chatbot Integration
This repository contains:

A Laundry Management App built using Flutter & Firebase

AI Chatbot Files using FLAN-T5 trained to assist users via a chatbot in the app

🚀 Getting Started
📱 Flutter Laundry App
This is a Flutter-based mobile app that helps students and staff manage laundry services with separate logins.

✅ Features
Firebase Email/Password Authentication

Firestore Database for user and order data

Role-based login for Students and Staff

Profile editing and order management

AI chatbot integration (via API)

📦 Dependencies
Make sure to run:

bash
Copy
Edit
flutter pub get
📂 Firebase Setup
Add your google-services.json (for Android) or GoogleService-Info.plist (for iOS).

Configure Firebase Authentication and Firestore in your Firebase Console.

🧪 Testing the App Locally
bash
Copy
Edit
flutter run
🤖 AI Chatbot (FLAN-T5)
Located inside the laundry_ai_files/ folder.

📁 Includes:
flan_model_code.py: Python script to load and run the FLAN-T5 model

data.json: Training data used for fine-tuning

requirements.txt: All Python dependencies

flan_response_api.py: Flask API to serve responses

model_weights_link.txt: A GitHub link to download the .pth model file

🛠️ Setup Instructions
Create a virtual environment (optional but recommended):

bash
Copy
Edit
python -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
Install dependencies:

bash
Copy
Edit
pip install -r requirements.txt
Download the model weights:

Open model_weights_link.txt and download the .pth file.

Place it in the same directory as your model loading code.

Run the Flask API:

bash
Copy
Edit
python flan_response_api.py
The API will be hosted locally (e.g., http://127.0.0.1:5000/get-response)

🔄 Connecting Flutter App to AI API
Use http POST requests in Dart to send messages to /get-response endpoint.

Response is returned as a JSON object with the AI's reply.

🧾 Folder Structure
bash
Copy
Edit
├── lib/                    # Flutter app source code
│   ├── main.dart
│   └── ...
├── android/ios/            # Platform-specific files
├── laundry_ai_files/       # Python code for FLAN-T5 AI model
│   ├── flan_model_code.py
│   ├── data.json
│   ├── model_weights_link.txt
│   └── ...
├── .gitignore
├── pubspec.yaml
└── README.md
✍️ Author & Maintainer
Keshav – [Bennett University | BTech CSE]

Contact: DM me via GitHub or connect on campus 👨‍💻
