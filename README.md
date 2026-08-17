# PedsFlow

**Version:** 20.3.0+2030  
**Release date:** August 17, 2026  
**Status:** Clean full-source release

PedsFlow is a Flutter pediatric clinical reference and decision-support application. This clean release consolidates the current source into one project and removes historical patch installers, generated Flutter state, and obsolete release-note files from the project root.

## Included in this release

- Current PedsFlow clinical modules and calculators
- PCCU procedural sedation content
- Neonatal and Endocrine hubs
- Electrolyte replacement tools
- Stackable hypokalemia potassium-plan builder
- Global Search v2
- Bilirubin and DKA engines
- Current web/PWA files and GitHub Pages workflow
- Proprietary PedsFlow license and third-party notice
- LHSC / Children's Hospital of Western Ontario PCCU 2020 handbook medication overlay (411 medication entries total)

## Build

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href "/pedsflow/"
```

GitHub Actions on `main` performs dependency installation, analysis, tests, the Flutter web build, and GitHub Pages deployment.

## Project structure

- `lib/` - application source
- `assets/` - clinical/reference data and branding assets
- `test/` - automated checks
- `web/` - Flutter web/PWA shell
- `.github/workflows/` - deployment workflow
- `pubspec.yaml` - Flutter package metadata/dependencies
- `LICENSE` - PedsFlow proprietary license
- `THIRD_PARTY_NOTICE.md` - third-party rights notice

## Clinical disclaimer

PedsFlow is a clinical decision-support and educational reference. Verify medication dosing, concentrations, thresholds, monitoring, and treatment decisions against current authoritative references, institutional policy, pharmacy guidance, and supervising clinicians before patient care.

## Copyright

Copyright (c) 2026 Ahmed Saleh. All Rights Reserved. See `LICENSE`.
