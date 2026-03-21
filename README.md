# P2P Electric Motorbike Rental System - Frontend

A modern, feature-rich Flutter application for a peer-to-peer electric motorbike rental platform. Connect riders with vehicle owners seamlessly across multiple platforms.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Environment Setup](#environment-setup)
- [Usage](#usage)
- [Build & Release](#build--release)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Overview

**P2P Electric Motorbike Rental System** is a comprehensive Flutter frontend application designed to revolutionize electric motorbike sharing. The platform enables users to rent electric motorbikes from peers, track trips in real-time, manage bookings, process payments, and leave reviews—all from a single, intuitive interface.

### Target Users & Use Cases

- **Renters**: Browse available bikes, book rentals, track trips, and manage payments
- **Owners**: List vehicles, manage bookings, track rentals, and earn revenue
- **Travelers**: Access convenient, eco-friendly transportation solutions
- **Urban Commuters**: Reduce commute times with flexible bike-sharing options

---

## Features

- 🏍️ **Browse & Book Vehicles** - Discover available electric motorbikes with detailed information and pricing
- 📍 **Real-Time Location Tracking** - Track active trips on an integrated Google Maps interface
- 🔐 **Secure Authentication** - Firebase-powered user authentication and session management
- 💳 **Payment Integration** - Secure payment processing with multiple payment methods
- ⭐ **Review & Rating System** - Leave and view reviews for vehicles and users
- 🔔 **Push Notifications** - Real-time alerts for bookings, trip updates, and system messages
- 📱 **Multi-Platform Support** - iOS, Android, Web, Windows, macOS, and Linux
- 🎨 **Modern UI/UX** - Beautiful, responsive interface with smooth animations
- 📊 **Trip History** - Comprehensive booking and rental history with trip details
- 🗺️ **Location Services** - Geocoding and geolocation features for enhanced navigation
- 🌐 **Real-Time Communication** - WebSocket integration for live updates

---

## Screenshots

| Feature       | Preview                                                                  |
| ------------- | ------------------------------------------------------------------------ |
| Home Screen   | ![Home](https://via.placeholder.com/300x600?text=Home+Screen)            |
| Booking Flow  | ![Booking](https://via.placeholder.com/300x600?text=Booking+Flow)        |
| Trip Tracking | ![Trip Tracking](https://via.placeholder.com/300x600?text=Trip+Tracking) |
| Payment       | ![Payment](https://via.placeholder.com/300x600?text=Payment+Screen)      |

_Screenshots are placeholders. Replace with actual app screenshots._

---

## Tech Stack

### Framework & Language

- **Flutter**: 3.10.1+
- **Dart**: Latest stable version
- **Target Platforms**: iOS, Android, Web, Windows, macOS, Linux

### State Management

- **Flutter BLoC**: `flutter_bloc: ^8.1.6` - Business Logic Component for reactive programming

### Networking & Communication

- **Dio**: `dio: ^5.4.3+1` - HTTP client for API requests
- **Socket.IO**: `socket_io_client: ^2.0.3` - Real-time bidirectional communication
- **Firebase Core**: `firebase_core: 2.24.2` - Firebase initialization
- **Firebase Messaging**: `firebase_messaging: 14.7.10` - Push notifications

### UI & Design

- **Google Fonts**: `google_fonts: ^6.2.1` - Custom typography
- **Cupertino Icons**: `cupertino_icons: ^1.0.8` - iOS-style icons
- **Flutter Spinkit**: `flutter_spinkit: ^5.2.1` - Loading animations
- **Bot Toast**: `bot_toast: ^4.1.3` - Toast notifications

### Location & Maps

- **Google Maps Flutter**: `google_maps_flutter: ^2.9.0` - Map integration
- **Geolocator**: `geolocator: ^12.0.0` - Device location services
- **Geocoding**: `geocoding: ^3.0.0` - Address-to-coordinates conversion
- **Image Picker**: `image_picker: ^1.2.1` - Camera and gallery access

### Dependency Injection

- **GetIt**: `get_it: ^7.7.0` - Service locator
- **Injectable**: `injectable: ^2.4.4` - Code generation for GetIt

### Storage & Security

- **Flutter Secure Storage**: `flutter_secure_storage: ^9.2.2` - Encrypted local storage

### Navigation

- **GoRouter**: `go_router: ^14.6.2` - Declarative routing system

### Utilities

- **Formz**: `formz: ^0.7.0` - Form validation
- **Dartz**: `dartz: ^0.10.1` - Functional programming tools
- **Equatable**: `equatable: ^2.0.5` - Equality comparison
- **Intl**: `intl: ^0.19.0` - Internationalization
- **Logger**: `logger: ^2.0.2+1` - Debugging logger
- **URL Launcher**: `url_launcher: ^6.3.2` - Open external URLs
- **File Picker**: `file_picker: ^8.1.6` - File selection

### Local Notifications

- **Flutter Local Notifications**: `flutter_local_notifications: ^16.3.0` - Local push notifications

---

## Project Structure

```
lib/
├── main.dart                          # Entry point of the application
├── firebase_options.dart              # Firebase configuration
├── injection_container.dart           # Dependency injection setup
│
├── core/                              # Core functionality (shared across features)
│   ├── constants/                     # App-wide constants
│   ├── error/                         # Error handling classes
│   ├── network/                       # Network configuration
│   ├── router/                        # Navigation routes
│   ├── services/                      # Core services (auth, notifications)
│   ├── storage/                       # Local storage and preferences
│   ├── theme/                         # App theme and styling
│   ├── usecases/                      # Base classes for use cases
│   ├── utils/                         # Utility functions and helpers
│   └── widgets/                       # Reusable UI components
│
└── features/                          # Feature modules (clean architecture)
    ├── auth/                          # Authentication (login, signup, logout)
    ├── booking/                       # Booking management
    ├── main/                          # Main/home feature
    ├── notification/                  # Notifications and alerts
    ├── owner_vehicle/                 # Vehicle management for owners
    ├── payment/                       # Payment processing
    ├── renter/                        # Renter-specific features
    ├── review/                        # Reviews and ratings
    ├── trip/                          # Trip management and tracking
    └── vehicle/                       # Vehicle browsing and details
```

### Architecture Pattern

This project follows **Clean Architecture** principles with a feature-based structure. Each feature module contains:

- **Data** layer (repositories, data sources)
- **Domain** layer (entities, use cases)
- **Presentation** layer (BLoCs, pages, widgets)

---

## Installation

### Prerequisites

- Flutter SDK 3.10.1 or higher
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- Git

### Step-by-Step Setup

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/p2p-emrs-fe.git
   cd p2p-emrs-fe
   ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate Code (for injectable and build_runner)**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application**

   For Android:

   ```bash
   flutter run -d android
   ```

   For iOS:

   ```bash
   flutter run -d ios
   ```

   For Web:

   ```bash
   flutter run -d web --web-renderer html
   ```

   For Windows/macOS/Linux:

   ```bash
   flutter run -d windows
   flutter run -d macos
   flutter run -d linux
   ```

---

## Environment Setup

### Firebase Configuration

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one

2. **Add Your App to Firebase**
   - Add Android, iOS, and Web apps to your Firebase project
   - Download configuration files:
     - `google-services.json` for Android → place in `android/app/`
     - `GoogleService-Info.plist` for iOS → place in `ios/Runner/`

3. **Configure Web (if using web platform)**
   - Firebase will provide web configuration snippet
   - Update `lib/firebase_options.dart` with your configuration

### API Configuration

Create a `.env` file in the project root (or configure through your backend service):

```env
API_BASE_URL=https://your-api-endpoint.com
API_TIMEOUT=30
```

### Google Maps API Key

1. **Enable Google Maps API** in Google Cloud Console
2. **Generate API Key** for both Android and iOS
3. **Configure in native files**:
   - Android: `android/app/src/main/AndroidManifest.xml`
   - iOS: `ios/Runner/Info.plist`

---

## Usage

### Launching the App

After running `flutter run`, the app will launch with the following main screens:

1. **Authentication Screen** - Sign up or log in
2. **Home/Dashboard** - Browse available vehicles or view your listings
3. **Booking Flow** - Select a vehicle and complete reservation
4. **Trip Details** - View active trip with real-time tracking
5. **Payment Screen** - Secure payment processing
6. **Review Screen** - Leave feedback after trip completion
7. **Profile** - Manage account settings and preferences

### Key User Workflows

**For Renters:**

1. Browse available vehicles with filters
2. Select desired vehicle and dates
3. Complete booking and payment
4. Track trip on map in real-time
5. Leave review upon completion

**For Owners:**

1. List your electric motorbikes
2. Manage owner vehicles and pricing
3. Accept/decline booking requests
4. Track rental history and earnings
5. Respond to customer reviews

---

## Build & Release

### Android APK/AAB

Build APK:

```bash
flutter build apk --release
```

Build App Bundle (for Play Store):

```bash
flutter build appbundle --release
```

Output location: `build/app/outputs/`

### iOS Build

Build for iOS:

```bash
flutter build ios --release
```

Options for submission:

- Build and archive in Xcode:
  ```bash
  flutter build ios --release
  open ios/Runner.xcworkspace
  ```

### Web Build

Build for web:

```bash
flutter build web --release
```

Output location: `build/web/`

### Desktop Builds (Windows/macOS/Linux)

Windows:

```bash
flutter build windows --release
```

macOS:

```bash
flutter build macos --release
```

Linux:

```bash
flutter build linux --release
```

---

## Contributing

We welcome contributions! Please follow these guidelines:

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit changes: `git commit -m "Add your feature"`
4. Push to branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

### Code Standards

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before submitting PR
- Write meaningful commit messages
- Add comments for complex logic
- Test your changes thoroughly

### Reporting Issues

- Provide a detailed description
- Include steps to reproduce
- Specify Flutter and Dart versions
- Attach relevant screenshots or logs

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## Contact

For questions, suggestions, or support, please reach out:

- **Project Lead**: [Your Name] - [your.email@example.com]
- **GitHub Issues**: [Create an issue](https://github.com/yourusername/p2p-emrs-fe/issues)
- **Documentation**: [Wiki](https://github.com/yourusername/p2p-emrs-fe/wiki)

---

**Happy coding! 🚀**
