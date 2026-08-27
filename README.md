# JobTrail

JobTrail is a cross-platform Flutter application for organizing and tracking job applications throughout the hiring process.

The project is being developed as a production-minded portfolio application, with a focus on clean architecture, maintainable code, responsive UI, and automated testing.

## Features

- View a dashboard with application, interview, and offer statistics
- Filter applications by status
- Add applications with company, role, location, status, and optional notes
- View complete application details
- Edit existing applications using a reusable form
- Delete applications with a confirmation dialog
- Generate company initials automatically
- Validate required form fields
- Update dashboard data and statistics reactively

## Application Statuses

- Applied
- Interview
- Offer
- Rejected

## Architecture

JobTrail uses a feature-first structure with a lightweight MVVM and Repository approach:

```text
lib/
├── app/
│   └── jobtrail_app.dart
├── core/
│   └── app_theme.dart
└── features/
    └── applications/
        ├── data/
        │   └── application_repository.dart
        ├── domain/
        │   └── job_application.dart
        └── presentation/
            ├── application_details_page.dart
            ├── application_details_result.dart
            ├── application_form_sheet.dart
            ├── applications_view_model.dart
            └── dashboard_page.dart
```

- **Domain** contains the core application model and status definitions.
- **Data** provides the repository abstraction and current in-memory implementation.
- **Presentation** contains screens, reusable UI, navigation results, and state management.
- **ViewModel** coordinates UI actions and notifies widgets when application data changes.

## Technical Highlights

- Flutter and Dart
- Material 3 interface
- `ChangeNotifier` and `ListenableBuilder` for state updates
- Reusable add/edit application form
- Type-safe navigation results using sealed classes
- Repository abstraction for separating data access from UI logic
- Widget tests covering the main user flows

## Tests

The widget test suite currently covers:

- Dashboard content
- Add-application form
- Details navigation
- Application editing
- Application deletion

Run the checks with:

```bash
flutter analyze
flutter test
```

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android device, Android emulator, or another Flutter-supported target

### Installation

```bash
git clone https://github.com/aliyoussefhamo/jobtrail.git
cd jobtrail
flutter pub get
flutter run
```

## Roadmap

- [x] Application dashboard
- [x] Status filtering
- [x] Create, view, update, and delete applications
- [x] Optional application notes
- [x] Widget tests for core user flows
- [ ] Local persistence with SQLite
- [ ] Application search
- [ ] Sorting and advanced filtering
- [ ] Interview reminders and notifications
- [ ] Improved test coverage
- [ ] App branding and release assets

## Current Project Status

JobTrail is under active development. Application data is currently stored in memory and resets when the app restarts. Local SQLite persistence is the next planned feature.

## Author

**Ali Hamo** — Software Engineer | Flutter & iOS Developer

- [LinkedIn](https://www.linkedin.com/in/ali-hamo-5a814a21b/)
- [GitHub](https://github.com/aliyoussefhamo)
