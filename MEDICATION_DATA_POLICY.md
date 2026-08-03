# Medication Data Policy

Each medication can contain three source layers:

- Current Ontario emergency data from CHEO
- Current Canadian hospital monograph text from IWK
- Historical local data from the uploaded PCCU card

The application does not synthesize or interpolate missing doses. A catalogue entry without imported dose data remains searchable but shows no dose.

Source dates are displayed in the medication interface. Future updates should be source-versioned and regression-tested before deployment.
