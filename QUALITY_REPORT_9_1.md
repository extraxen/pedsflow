# PedsFlow 9.1 Quality Report

- plans: 130
- medications: 300
- medications_with_doses: 209
- dart_files_structurally_validated: 24
- new_screens: ['medication_quality_screen.dart', 'backup_screen.dart']

Run locally before publishing:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
