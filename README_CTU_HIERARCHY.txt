PedsFlow v20.5.1 CTU HIERARCHY CLEANUP

New hierarchy:
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

This assumes the v20.5.1 Home navigation repair has already been applied successfully.

INSTALL
Copy/extract these files into:
C:\Users\drham\pedsflow_v2

Run:
cd C:\Users\drham\pedsflow_v2
powershell -ExecutionPolicy Bypass -File .\install_ctu_hierarchy_cleanup.ps1

Then run ONLY:
flutter analyze

If clean:
flutter test

Then:
flutter build web --release --base-href "/pedsflow/"

Do not commit until all three pass.
