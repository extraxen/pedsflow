# Endocrine module clinical specification and safety register

**Last source review:** 2026-10-25
**Scope:** DI / AVP-D/AVP-R observations; educational starting/observed TDD, basal/bolus, ICR, ISF, meal and correction arithmetic; IV-to-SC and pump reference.
**Approval status:** NOT CLINICALLY VALIDATED AT SICKKIDS. Clinical governance, medication safety and pediatric endocrine staff review are required before using new tools in patient care.

## Existing implementation reviewed
The existing `lib/features/endocrine/endocrine_hub_screen.dart` combined emergency reference pages and an insulin calculator. Its historical pre-filled sample inputs, automatically propagated 500/100-rule estimates, and automatically shown combined insulin estimate were removed from active navigation. Existing adrenal, hypoglycemia, thyroid and calcium pages were retained unchanged, as was the independent DKA engine.

## Pure functions and formulas

| Function | Inputs -> output | Formula | Status / source |
| --- | --- | --- | --- |
| `estimatedIcr(TDD, rule)` | U/day -> g carbohydrate/U | `rule / TDD` for clinician-selected rule 500, 330 or 250 | Initial rough estimate; ISPAD 2024, ch. 9, p. 596 |
| `estimatedIsf(TDD)` | U/day -> mmol/L/U | `100 / TDD` | Initial rough estimate for rapid-acting insulin; ISPAD 2024, ch. 9, p. 597 |
| `glucoseMgDl` | mmol/L -> mg/dL | `mmol/L * 18.0182` | Glucose molar-mass conversion |
| `glucoseMmolL` | mg/dL -> mmol/L | `mg/dL / 18.0182` | Glucose molar-mass conversion |
| `mealUnits` | g carbohydrate, **prescribed** ICR in g/U -> U | `grams / ICR` | Only based on explicit patient settings |
| `correctionUnits` | current, target mmol/L and **prescribed** ISF mmol/L/U -> U | `max(0, (current-target)/ISF)` | Arithmetic only, no IOB adjustment |
| `estimatedTddFromWeight` | weight kg and clinician-selected U/kg/day -> U/day | `kg * U/kg/day` | ISPAD 2024 ch. 9 p. 594; no preset factor; NOT an insulin order |
| `observedTdd` | completed basal and delivered boluses in same past 24h -> U/day | `basal U + bolus U` | SickKids AboutKidsHealth past-24h approach; verify complete delivered totals |
| `bolusFromTotalAndBasal` | TDD U and daily basal U -> U/day | `TDD - basal` | Pure arithmetic, no division into meal doses |
| `basalPercentOfTdd` | observed basal and completed TDD -> % | `(basal / TDD) * 100` | Descriptive analysis, not a target |
| `tddPerKg` | TDD U/day and weight kg -> U/kg/day | `TDD / kg` | Arithmetic, avoid interpretation without age/puberty context |
| `basalFromApprovedPercentage` | clinician-approved TDD U/day and chosen % -> U/day | `TDD * percentage / 100` | Arithmetic only; not a suggested basal proportion |
| `nearestIncrement` | calculated U, clinician-selected delivery resolution in U | `round(U/step) * step` | Illustration only; not an insulin order |
| `urineOutputMlKgHour` | actual observed urine mL, weight kg, duration h -> mL/kg/h | `mL / kg / hours` | Measured output, not a fluid order |

The ISPAD 500 rule does not apply uniformly across pediatric ages: ISPAD discusses 330/250 alternatives in preschoolers and meal-specific variation. The 100 rule in mmol/L corresponds approximately (not identically) to the 1800 rule in mg/dL. Where another rapid insulin formula applies, the clinician must use individualized dosing; this app does not infer a new rule.

## DI clinical interpretation

Source: Royal Children's Hospital Melbourne, *Clinical Practice Guideline: Diabetes insipidus* (July 2022 update). A pediatric polyuria threshold discussed by RCH is urine output **>4 mL/kg/h averaged over six hours**. High serum osmolality with inappropriately dilute urine raises concern but does NOT distinguish central AVP deficiency from nephrogenic AVP resistance. The app deliberately exposes observation arithmetic and flags only, not a DI subtype diagnosis.

The alert for Na >=170 mmol/L follows the RCH severe hypernatremia escalation threshold. A result from 150 to 169 mmol/L may also require cautious expert management. Do **not** use standalone free-water deficit formulas or one-size-fits-all sodium correction rates without an institutional pathway, particularly in infants and nephrogenic DI. Water deprivation and desmopressin administration require specialist management. Never restrict access to drinking water in a child with suspected/confirmed DI who can drink safely, except under a carefully specified specialist plan for a different established diagnosis.

## Transition and pump

The SC transition page does not generate insulin orders or derive TDD from body weight. The separate TDD/Basal page can calculate an educational weight-based estimate only with a deliberately clinician-entered U/kg/day factor; it is not transferred into transition orders or prescribed ICR/ISF inputs. It displays arithmetic for clinician-approved TDD and basal percentage and a clearly fictional example. It quotes NICE NG18, sections 1.4.42–1.4.45, as an **external** pediatric reference: SC insulin at least 30 min before IV discontinuation; when restarting a pump, at least 60 min overlap with new infusion set, site and cartridge. This is **not** a verified SickKids transition order set; long-acting insulin overlap varies by pharmacology and local protocols.

ISPAD 2024 Technology: Insulin Delivery warns that pump infusion-set failure can rapidly cause DKA. No automatic basal profile, AID parameter, action time or patient-specific backup dose is generated. Pump setup always requires an endocrinology team/device plan.

## Input validation and fail-closed limits

- Numeric inputs require finite values. Blank, negative, infinite, NaN and zero-divisor inputs do not return doses.
- Fixed upper bound checks are conservative data-entry safeguards, NOT clinical exclusion thresholds (e.g. weight >300 kg, factor >5 U/kg/day, estimated TDD >500 U/day, current glucose >60 mmol/L, carbohydrate >500 g). Outside those ranges, the UI refuses arithmetic and requires manual expert verification.
- No positive combined insulin result is shown if entered current glucose <3.9 mmol/L.
- No positive combined result is shown without *both* explicitly supplied ICR and ISF plus review acknowledgement; no estimates are copied into those fields.
- No active-insulin subtraction, pump algorithm simulation, hypoglycemia-specific reduction or device-dependent rounding is automated.
- Rounding is **never silently applied**. Optional nearest-step arithmetic requires the actual device increment; clinicians must independently decide whether to round down/up under the prescribed plan.
- Lab flagging should not be used with values supplied in another unit.
- Manual entry does not guarantee a prescribed setting is current or appropriate.

## Guidelines and precise sections

1. ISPAD Clinical Practice Consensus Guidelines 2024, chapter 9 (published online Jan 30, 2025), *Insulin and Adjunctive Treatments in Children and Adolescents with Diabetes*, pp. 594 and 596-597. DOI 10.1159/000543169. https://www.ispad.org/static/3b8e00b2-9f33-43a5-a84f9eda1accef64/ICPCG-Chapter-9-2024.pdf
2. ISPAD Clinical Practice Consensus Guidelines 2024, chapter 16, *Diabetes Technologies – Insulin Delivery*, DOI 10.1159/000543034. https://pmc.ncbi.nlm.nih.gov/articles/PMC11854989/
3. Royal Children's Hospital Melbourne, *Diabetes insipidus* CPG (July 2022 update). https://www.rch.org.au/clinicalguide/guideline_index/diabetes_insipidus/
4. NICE, *Diabetes (type 1 and type 2) in children and young people*, NG18 sections 1.4.42–1.4.45. https://www.nice.org.uk/guidance/ng18/chapter/recommendations
5. Nova Scotia Health, *Bolus Insulin Use in Children/Adolescents with Type 1 Diabetes*, 2025: confirms age-sensitive 500/330/250 discussion. https://physicians.nshealth.ca/sites/default/files/2025-06/Insulin%20Dose%20Adjustment%20Guidelines%202025_0.pdf

## Outstanding institutional clinical verification

1. Obtain approved SickKids ICR/ISF new-onset and established T1D protocols, especially young-child, breakfast and MDI versus pump assumptions.
2. Review SickKids transition eligibility, basal pharmacokinetics, timing of first SC insulin and specific IV-stop instructions with pediatric endocrinology and pharmacy.
3. Review pump manufacturer's AID-specific targets, DIA/IOB and infusion failure instructions. Ensure patient-specific backup injection plans.
4. Review SickKids inpatient DI and nephrogenic DI pathways, sodium observation frequency, free-water prescriptions and DDAVP policies. Neonatal cases need separate review.
5. Confirm user-interface calculator display on iPhone/Android/desktop, test screen reader and contrast, evaluate scenario-based medication safety, and obtain formal clinical sign-off.
6. CI runs `flutter analyze`, `flutter test` and `flutter build web`; passing CI does not equal clinical validation.

**If released as an educational reference, it remains NOT CLINICALLY VALIDATED AT SICKKIDS. Do not use the TDD/basal calculations, ICR/ISF estimates, fluid advice or transition pages as independent prescribing instructions without institution-specific review.**
