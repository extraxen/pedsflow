PedsFlow v20.5.1 ASCII NAVIGATION REPAIR

This installer is ASCII-only and avoids:
- PowerShell here-strings
- Unicode bullets/subscripts in the installer
- broad regex block deletion

It first restores these files from known-good commit 7b5ec38:
- lib/screens/home_screen.dart
- lib/screens/app_shell.dart
- lib/screens/calculators_screen.dart

Then it applies the complete desired hierarchy:

Home
CTU
  - Admission Plans
  - Growth Suite
Medications
Calculators
  - Electrolyte Replacement Engine
  - existing calculators
PCCU
Library

It also removes redundant Home cards:
- Growth Suite
- Electrolyte Replacement Engine
- Hypokalemia replacement engine
- PCCU
- ED/PICU decision support

INSTALL
Copy ZIP contents into:
C:\Users\drham\pedsflow_v2

Run:
cd C:\Users\drham\pedsflow_v2
powershell -ExecutionPolicy Bypass -File .\repair_and_install_navigation.ps1

Then run ONLY:
flutter analyze
