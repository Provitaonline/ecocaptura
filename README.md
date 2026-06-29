# ecocaptura

## **Currently under development**

A Flutter mobile application for photos-based ecological data collection.

## Features

TBD

## Project Structure

```
lib/
├── core/                  # Shared services and localization files
│   ├── l10n/              # ARB dictionaries and manual localization controllers
│   └── services/          # Device sensor and telemetry managers
├── features/              # Feature modules
│   └── dashboard/         # Main UI
└── utils/                 # Global helper classes, constants, and extensions
```

## Setup

### Prerequisites
	Flutter SDK
	Android SDK (API 28+)
	Xcode (Required for future iOS deployment)

### Commands

Fetch dependencies and generate translation files:

```
flutter pub get
flutter gen-l10n
```

Run the application

```
flutter run
```
---

*This project is being developed with the assistance of Google Gemini.*
