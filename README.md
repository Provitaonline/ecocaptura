# ecocaptura

## **Currently under development**

A Flutter mobile application for photos-based ecological data collection.

## Features

### Features

* **Offline Data Capture:** Captures and stores photos and metadata locally for remote field use.
* **Structured Captures:** Supports grouping multiple photos under a single record, including quality ratings and descriptive metadata.
* **Editable Drafts:** Captures remain editable until they are finalized and marked for cloud synchronization.
* **Comprehensive Sensor Logging:** Every photo logs precise metadata, including location, elevation, heading, tilt, roll, field-of-view (FOV), and raw sensor readings.
* **Data Export:** Packages photos and metadata into a single bundle for external sharing.
* **Cloud Synchronization:** Supports structured uploads of all media and associated metadata to the cloud.
* **Localization:** Fully localized with support for English and Spanish.

## Project Structure

```
lib/
├── core/                  # Shared services and localization files
│   ├── constants/
│   ├── extensions/
│   ├── l10n/              # ARB dictionaries and manual localization controllers
│   └── services/          # Preferences, device sensor and telemetry managers
├── features/              # Feature modules
│   ├── data/              # data model and storage services
│   └── presentation/      # UI
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
