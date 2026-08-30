PedsFlow v20.5.1 NAVIGATION CLEANUP REPAIR

WHY
The previous cleanup installer used a broad regex that corrupted home_screen.dart.
The large number of analyzer errors are cascading syntax errors from that one file.

WHAT THIS REPAIR DOES
1. Restores lib/screens/home_screen.dart exactly from known-good commit 7b5ec38
   (PedsFlow v20.5.0 NICU feeding-plan release).
2. Removes only three exact Home shortcut blocks:
   - Hypokalemia replacement engine
   - PCCU
   - ED/PICU decision support
3. Removes only their now-unused Home imports.
4. Keeps all underlying feature files intact.
5. Does not touch the NICU feeding-plan files.

INSTALL
Copy repair_navigation_cleanup.ps1 into:
C:\Users\drham\pedsflow_v2

Then run:
cd C:\Users\drham\pedsflow_v2
powershell -ExecutionPolicy Bypass -File .\repair_navigation_cleanup.ps1

THEN RUN ONLY:
flutter analyze

If analyze is clean, then run separately:
flutter test

Then:
flutter build web --release --base-href "/pedsflow/"

Do not commit until all three pass.
