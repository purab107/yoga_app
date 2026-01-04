# Yoga App - Flutter

A simple Flutter application for yoga pose analysis with a clean, minimal UI.

## Features

- **Splash Screen**: App launch with fade-in animation
- **Home Screen**: Main dashboard with primary action and locked exercise cards
- **Asana Selection**: Grid view of 10 yoga asanas
- **Video Upload**: Mock video selection for analysis
- **Processing**: Loading screen with animation
- **Results**: Display feedback and navigation options

## Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart
│   └── screens/
│       ├── splash_screen.dart
│       ├── home_screen.dart
│       ├── asana_selection_screen.dart
│       ├── video_upload_screen.dart
│       ├── processing_screen.dart
│       └── results_screen.dart
├── pubspec.yaml
└── README.md
```

## How to Run

1. Ensure Flutter is installed:
   ```bash
   flutter doctor
   ```

2. Navigate to the flutter_app directory:
   ```bash
   cd d:\yoga_app\flutter_app
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Supported Asanas

- Anantasana
- Ardhakati Chakrasana
- Bhujangasana
- Kati Chakrasana
- Marjariasana
- Parvatasana
- Sarvangasana
- Tadasana
- Vajrasana
- Viparita Karani

## Notes

- This is a UI-only implementation
- No backend integration
- No ML processing
- All data is hardcoded
- Mock video selection functionality
- Clean navigation flow between screens

## Design Language

- Primary color: Deep Purple
- Clean, minimal UI
- Material Design components
- Simple animations and transitions
