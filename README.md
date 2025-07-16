
Welcome to the LNMIIT Campus App – your all-in-one companion for navigating and experiencing life at The LNM Institute of Information Technology (LNMIIT), Jaipur! This mobile application aims to streamline campus information, events, and essential services for students, faculty, and staff.

✨ Features
The LNMIIT Campus App offers a comprehensive suite of features designed to enhance your campus experience:

User Authentication: Secure login and signup powered by Firebase Authentication.

Personalized Profile: View and edit your personal details, including name, email, phone, roll number, department, and campus.

Campus Events: Stay updated with all college events, including technical fests, cultural programs, and workshops. Users can add new events, and existing events are displayed with details like title, date, time, location, and description.

Lost & Found: A dedicated section to report and view lost or found items on campus, helping the community connect and retrieve belongings. Includes image upload for items.

AI Chatbot: An intelligent campus assistant powered by the Groq API (with local fallbacks) to answer queries about campus facilities (library, mess, gym), academics, hostels, transportation, medical services, Wi-Fi, and more.

Interactive Campus Map: Navigate the campus with an integrated Google Map, search for specific locations, and find your current position.

Feedback System: Provide valuable feedback on various campus services like teachers, mess, canteen, and library with a star rating system.

Transport Scheduler: (Placeholder/Future Feature) A module to manage and view transportation schedules (e.g., bus timings).

Maintenance Tracker: (Placeholder/Future Feature) A module for reporting and tracking maintenance issues on campus.

🛠️ Technologies Used
Framework: Flutter

Backend: Firebase (Firestore for database, Authentication for user management, Cloud Storage for image uploads)

Mapping: google_maps_flutter, geocoding, geolocator, permission_handler

AI/LLM: Groq API (for the AI Chatbot)

Image Handling: image_picker, cached_network_image, uuid

Date/Time Formatting: intl

HTTP Requests: http

🚀 Installation
To get a local copy of the project up and running, follow these steps:

Prerequisites
Flutter SDK installed (version 3.x.x or higher recommended)

Dart SDK

Firebase CLI installed and configured

Google Cloud Project with Billing Enabled (for Google Maps API Key and Firebase)

1. Clone the repository
git clone https://github.com/your-username/lnmiit-campus-app.git
cd lnmiit-campus-app

2. Install Dependencies
flutter pub get

3. Firebase Setup
Create a Firebase Project: Go to Firebase Console and create a new project.

Add Android/iOS Apps: Follow the Firebase instructions to add Android and iOS apps to your project. This will involve downloading google-services.json (for Android) and GoogleService-Info.plist (for iOS) and placing them in the correct directories.

Enable Services:

Authentication: Enable "Email/Password" provider.

Firestore Database: Create a new Firestore database.

Cloud Storage: Enable Cloud Storage.

Firebase Rules: Configure your Firestore and Storage security rules to allow read/write access for authenticated users (or as per your security requirements).

4. Google Maps API Key Setup
Get API Key: Go to Google Cloud Console and create an API key. Enable the following APIs for your project:

Maps SDK for Android

Maps SDK for iOS

Geocoding API

Android Setup:

Open android/app/src/main/AndroidManifest.xml.

Add your API key inside the <application> tag:

<meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_GOOGLE_MAPS_API_KEY"/>

Ensure minSdkVersion in android/app/build.gradle is at least 20 (or higher as required by google_maps_flutter).

iOS Setup:

Open ios/Runner/AppDelegate.swift (or AppDelegate.m).

Add the following line before GeneratedPluginRegistrant.register(with: self):

GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")

Add privacy descriptions to ios/Runner/Info.plist:

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location when open to show your position on the map and find places near you.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location in the background for continuous tracking (if needed by other features).</string>

5. Groq API Key Setup
Get API Key: Sign up for a free API key at Groq.

Update Code: In lib/homepage/pages/ai_chatbot.dart, replace the placeholder _groqApiKey with your actual Groq API key:

static const String _groqApiKey = 'YOUR_GROQ_API_KEY_HERE';

Note: Hardcoding API keys directly in client-side code is not recommended for production apps due to security risks. For a real application, consider using environment variables, a server-side proxy, or Firebase Functions to manage API keys securely.

6. Run the App
flutter run

💡 Usage
Login/Signup: Create an account or log in to access the app's features.

Home Screen: Navigate to different modules using the grid tiles.

Profile: View your details and update editable information.

Events: Browse upcoming campus events or add new ones.

Lost & Found: Report lost items or check for found items.

AI Chatbot: Ask questions about LNMIIT campus life and facilities.

Campus Map: Explore the campus, search for locations, and find your current position.

Feedback: Share your thoughts on various campus services.

🤝 Contributing
Contributions are welcome! If you have suggestions for improvements, new features, or bug fixes, please feel free to:

Fork the repository.

Create a new branch (git checkout -b feature/YourFeatureName).

Make your changes.

Commit your changes (git commit -m 'feat: Add new feature').

Push to the branch (git push origin feature/YourFeatureName).

Open a Pull Request.

Please ensure your code adheres to standard Flutter best practices and includes appropriate tests where applicable.

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

📧 Contact
For any questions or inquiries, please contact:

Name: Abhinav Mishra 
Gmail: abinavmishra61@gmail.com

Project Link: https://github.com/abhi2811mishra/Campus-App
