# PedsFlow Proprietary License Patch

This patch adds a proprietary copyright/license framework without replacing third-party licenses.

## Files

- `LICENSE` — PedsFlow Proprietary License v1.0.
- `THIRD_PARTY_NOTICE.md` — third-party/open-source/clinical-reference carve-out.
- `APPLY_PROPRIETARY_LICENSE.ps1` — adds:
  - README license notice
  - copyright headers to project-owned Dart files
  - visible "Proprietary software • All rights reserved" Home footer
  - web copyright metadata

## Apply

Extract this ZIP into the root of `C:\Users\drham\pedsflow_v2`, then run:

```powershell
cd C:\Users\drham\pedsflow_v2
.\APPLY_PROPRIETARY_LICENSE.ps1
flutter analyze
flutter test
```

Then commit and push the changes.

## Important

A public GitHub repository remains viewable/forkable through GitHub under GitHub's Terms of
Service. The proprietary license is intended to reserve additional reuse, redistribution,
commercialization and derivative-work rights; it does not make a public repository private.

This is a practical software-license template and should be reviewed by qualified legal counsel
before commercial licensing, institutional distribution, or reliance in a dispute.
