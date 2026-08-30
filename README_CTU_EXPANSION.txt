PedsFlow v20.5.1 EXPANDED CTU GROUPING

CTU now contains:
1. Admission Plans
2. Antibiotics & organisms
3. Pediatric Pain Management
4. Growth Suite

Home no longer shows separate cards for:
- Antibiotics & organisms
- Pediatric pain management

INSTALL
Copy the ZIP contents into:
C:\Users\drham\pedsflow_v2

Run:
cd C:\Users\drham\pedsflow_v2
powershell -ExecutionPolicy Bypass -File .\install_ctu_expansion.ps1

Then run ONLY:
flutter analyze

If clean, run tests/build afterward.
