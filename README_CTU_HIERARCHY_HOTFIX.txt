PedsFlow v20.5.1 CTU HIERARCHY CLEANUP HOTFIX

This replaces the prior installer that had a PowerShell here-string parser error.

New hierarchy:
- Home
- CTU
    - Admission Plans
    - Growth Suite
- Medications
- Calculators
    - Electrolyte Replacement Engine
    - existing calculators
- PCCU
- Library

INSTALL
Copy/extract the files into:
C:\Users\drham\pedsflow_v2

Then run:
cd C:\Users\drham\pedsflow_v2
powershell -ExecutionPolicy Bypass -File .\install_ctu_hierarchy_cleanup.ps1

Then run ONLY:
flutter analyze

If clean, report back before test/build.
