# 🚀 Rapid Mixer 2.0

A modern Flutter-based mobile application utilizing the latest mobile development technologies and tools for building responsive cross-platform applications.

---

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

---

## 🛠️ Installation

1. Clone this repository:

```bash
git clone https://github.com/your-username/rapid-mixer.git
cd rapid-mixer
Install dependencies:

bash
Copy
Edit
flutter pub get
Run the application:

bash
Copy
Edit
flutter run
📁 Project Structure
bash
Copy
Edit
rapid-mixer/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── presentation/   # UI screens and widgets
│   │   └── splash_screen/ # Splash screen implementation
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
🧩 Adding Routes
To add new routes to the application, update the lib/routes/app_routes.dart file:

dart
Copy
Edit
import 'package:flutter/material.dart';
import 'package:rapid_mixer/presentation/home_screen/home_screen.dart';
import 'package:rapid_mixer/presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes here
  };
}
🎨 Theming
This project includes a comprehensive theming system with both light and dark themes:

dart
Copy
Edit
ThemeData theme = Theme.of(context);

Color primaryColor = theme.colorScheme.primary;
Includes:

Color schemes

Typography

Input decorations

Buttons, Cards, Dialogs

📱 Responsive Design
Using Sizer for responsive layouts:

dart
Copy
Edit
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
📦 Deployment
Build for production:

bash
Copy
Edit
# For Android
flutter build apk --release

# For Web
flutter build web

# For iOS
flutter build ios --release
🙏 Acknowledgments
Built with Rocket.new

Powered by Flutter & Dart

Styled using Material Design

