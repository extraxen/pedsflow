# PedsFlow 10.0 — Pediatric Clinical Companion

Developed by **Dr. Ahmed Saleh**

## Core modules

- **200 pediatric admission plans**
- 300-medication catalogue
- Medication favourites, history and quality dashboard
- Antibiotics & Organisms reference
- 20 pediatric calculators
- Universal search
- Editable admission plans and personal notes
- Algorithm image library
- Backup and restore
- Clinical source and review-status display

## Run locally

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

## Build for GitHub Pages

For the `pedsflow` repository:

```powershell
flutter build web --release --base-href "/pedsflow/"
```

Copy the contents of `build\web` into the root of the cloned GitHub
Pages repository, preserving the hidden `.git` folder. Then commit and
push using GitHub Desktop.

## Clinical safety

PedsFlow is an educational and clinical-support reference developed by
Dr. Ahmed Saleh. It does not replace institutional policy, pharmacist
consultation, specialist advice or clinical judgment.

The 70 plans added in Version 10.0 are original structured summaries.
They are not copied hospital order sets and are labelled for local
clinical review. Medication dosing must be verified against current
Canadian and local sources before prescribing.
