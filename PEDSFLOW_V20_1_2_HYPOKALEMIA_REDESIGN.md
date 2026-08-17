# PedsFlow v20.1.2 — Hypokalemia Plan Builder

This patch replaces the prior route-switching hypokalemia calculator with a stackable bedside plan.

## Workflow

1. Patient: age, weight, current K, target K, magnesium, symptoms, ECG, urine output, renal risk.
2. Base IV fluid: select carrier fluid, rate, intrinsic K, and KCl additive.
3. KCl additive can be entered as 20 mmol/L, 40 mmol/L, custom mmol/L, or total mmol added to a selected bag volume.
4. Optional oral KCl: dose/kg, 20 mmol acute-dose cap, 1.33 mmol/mL default formulation, calculated mL.
5. Optional separate IV KCl: ward/critical-care/custom rate, duration, access, concentration, required carrier mL/hr.
6. Combined plan: exact potassium exposure over 1/2/4/6/12/24 hours and combined IV potassium rate while acute IV KCl is running.
7. Response context: pediatric published IV response comparators for 0.4, 0.5 and 1 mmol/kg regimens. Oral and maintenance-fluid serum rises are not assigned a false fixed conversion.
8. Monitoring and actual-response tracker.

## Safety behavior

- Counts potassium from the carrier fluid, added KCl, oral KCl and separate IV correction.
- Warns when background potassium causes the combined IV rate to exceed the selected ward/critical-care reference.
- Warns for peripheral concentrations above the usual cited 40 mmol/L reference and for >60 mmol/L without central access.
- Target K is for clinical context only and is not used to manufacture a total-body potassium deficit.
- Published IV serum-response estimates are shown only as research comparators and never combined mathematically with oral/maintenance-fluid effects.

Verify with local institutional protocols, formulary, pharmacist, and attending physician before implementation.
