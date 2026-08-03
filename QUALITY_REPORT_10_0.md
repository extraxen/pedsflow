# PedsFlow 10.0 Quality Report

- Admission plans: 200
- Unique plan IDs: 200
- Unique plan titles: 200
- Plans with exactly 12 sections: 200
- Specialties/categories: 16
- Medication entries preserved: 300
- Antibiotic syndrome guides preserved: 12
- Clinical source records: 6
- Dart files structurally checked: 25

## Category counts

- Allergy & Toxicology: 13
- Cardiology & Muscle: 12
- Child Protection: 1
- Complex Care: 1
- Endocrine & Metabolic: 16
- Gastroenterology: 21
- General Pediatrics & Trauma: 11
- Hematology & Oncology: 25
- Infectious Diseases: 27
- Neonatology: 12
- Nephrology: 11
- Neurology: 23
- Orthopedics & Trauma: 2
- Psychiatry & Behaviour: 2
- Respiratory: 20
- Surgery & Urology: 3

## Local validation required

The artifact environment does not contain the Flutter SDK. Before publishing, run:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
