# PedsFlow

**Version:** 20.13.0+2130
**Release date:** November 4, 2026
**Status:** Clean full-source release

PedsFlow is a Flutter pediatric clinical reference and decision-support application. This clean release consolidates the current source into one project and removes historical patch installers, generated Flutter state, and obsolete release-note files from the project root.

## Endocrine tools update (November 2026)

The Endocrine Hub now includes systemic steroid equivalence (educational only),
Katz/Hillier and distinct CPS corrected sodium estimates, standard and
albumin-adjusted anion gap, and effective/total calculated osmolarity with
optional osmolal gap. Each calculator is separately navigable with
transparent units, safety notes, and tests.

See docs/endocrine_lab_steroid_tools_2026.md for references, limitations and
the pending SickKids/local verification requirements.

## Neonatal thyroid evaluation (November 2026)

- Age-specific TSH and free T4 reference values transcribed from the supplied neonatal reference image, with explicit data gaps and assay-provenance warning.
- Guideline-grounded next-step assessment for possible primary/central congenital hypothyroidism, positive newborn screening, and premature/NICU infants.
- No autonomous levothyroxine orders; confirm serum specimen and verify local lab ranges before patient care.
- Full provenance, warnings, and boundaries: docs/neonatal_thyroid_reference_and_triage_2026.md.

## Included in this release

- Current PedsFlow clinical modules and calculators
- PCCU procedural sedation content
- Neonatal and Endocrine hubs
- Electrolyte replacement tools
- Stackable hypokalemia potassium-plan builder
- Global Search v2
- Bilirubin and DKA engines
- Current web/PWA files and GitHub Pages workflow
- Persistent vomiting/CVS admission plan with a stepwise antiemetic guide
- Pager Mode with 12 symptom-first overnight-call pathways and weight-based emergency dose cards
- Expanded Cardiology → ECG hub with a systematic interpretation guide, axis helper, rate and QTc calculators, and high-risk rhythm patterns
- Proprietary PedsFlow license and third-party notice
- Global clinical-safety footer with the full disclaimer available on every page
- Session-only patient weight calculator that shows supported weight-based medication doses while preserving the source rule for verification
- Keep Screen Awake control for supported browsers
- UTF-8 text normalization for clinical data to repair mojibake such as malformed bullets, dashes, arrows, degree signs, and Greek symbols
- Hard-coded UI Unicode integrity check to prevent Windows-1252/CP437 mojibake from being committed
- New Rheumatology / MSK pathways: swollen joint, rash + joint pain, JIA, systemic JIA/MAS, IgA vasculitis, pediatric SLE, juvenile dermatomyositis, and reactive/Lyme arthritis

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


### v20.3.1 search tuning
- Home search now explicitly covers diagnoses, medications, doses and clinical tools.
- Medication-focused quick searches added.
- Added common medication brand/colloquial aliases for faster lookup.

### v20.3.3 Home live-search tap fix
- Keeps live suggestions mounted while a query has results, even when the TextField loses focus during a tap.
- Direct suggestion taps now open the selected destination normally.
- Clears stale Home suggestions after opening a direct result.

### v20.7.0 Persistent vomiting and antiemetic pathway

- Added **Persistent vomiting / cyclic vomiting syndrome** under Gastroenterology admission plans.
- Added an ordered 12-part plan covering red flags, investigations, hydration, monitoring, consultations, reassessment and discharge readiness.
- Added layered treatment cards for first-line, antihistamine/anticholinergic, dopamine-antagonist/prokinetic, specialist antiemetic, CVS rescue, CVS prevention and GI/pain adjunct options.
- Added medication monographs for granisetron, palonosetron, chlorpromazine, fosaprepitant, scopolamine, sumatriptan, cyproheptadine and pizotifen.
- Added explicit safety stops for bilious/bloody/coffee-ground emesis, obstruction, QT-active medication stacking, EPS, sedation and respiratory depression.
